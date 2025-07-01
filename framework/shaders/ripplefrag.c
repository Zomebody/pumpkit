
#pragma language glsl3 // I don't remember why I put this here


varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragNormal; // used for normal map
varying vec3 fragWorldNormal;
varying vec4 fragPosLightSpace;

uniform float currentTime;
//uniform float diffuseStrength;
uniform vec3 ambientColor;

// shadow map properties
uniform vec3 sunColor = vec3(0.0); // used to brighten fragments that are lit by the sun
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform vec2 shadowCanvasSize;

// colors
uniform vec3 meshColor;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
uniform float meshBloom;
uniform vec2 meshFresnel; // x = strength, y = power
uniform vec3 meshFresnelColor; // vec3 since fresnel won't be supporting transparency (but still works on transparent meshes)

// textures
uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image normalMap;
// TODO: re-implement foaminess
// if noise1 < noise2 * foaminess, render foam
// thus if alpha values range from 0.1 to 0.9, you'll need a foaminess of at least 9 to have 100% foam coverage
// actually hold on that won't work because alpha values can't go > 1. Uhhh... I guess multiply by 10 and call it a day and just don't use foaminess values < 0.1?
uniform Image dataMap; // rg = distortion (angle & scalar), b = noise value for foam, a = foaminess (0 = no foam)
uniform vec3 foamColor; // xyz = color
uniform sampler2DShadow shadowCanvas; // use Image when doing 'basic' sampling. Use sampler2DShadow when you want automatic bilinear filtering (but more prone to shadow acne :<)
uniform vec4 waterVelocity; // x&y = water velocity, z&w = distortion velocity
uniform vec4 foamVelocity; // two directions & speeds at which the foams move





// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
// calculate shadow using sampler2DShadow, which uses bilinear filtering automatically for better shadows, but has bigger problems with shadow acne :<

float calculateShadow(vec4 fragPosLightSpace, vec3 surfaceNormal) {
	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// no shadows when outside the shadow canvas
	if (projCoords.x < 0.0 || projCoords.x > 1.0 || projCoords.y < 0.0 || projCoords.y > 1.0) {
		return 0.0;
	}

	float currentDepth = projCoords.z;

	// bias calc taken from: http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/#aliasing
	float cosTheta = clamp(dot(surfaceNormal, sunDirection), 0.0, 1.0);
	float bias = 0.00025 * tan(acos(cosTheta)); // cosTheta is dot( n,l ), clamped between 0 and 1
	bias = clamp(bias, 0, 0.00025); // used to be 0.005, but lowered because neighbor sampling works perfectly with reducing acne
	

	// sample depth at own position, but also sample 4 neighbors
	// THIS ACTUALLY YIELDS INCREDIBLE RESULTS, I AM A GENIUS!!
	
	vec2 texelSize = 1.0 / shadowCanvasSize;
	float s0 = texture(shadowCanvas, vec3(projCoords.xy, currentDepth - bias));
	float sl = texture(shadowCanvas, vec3(projCoords.xy + vec2(-texelSize.x, 0.0), currentDepth - bias));
	float sr = texture(shadowCanvas, vec3(projCoords.xy + vec2(texelSize.x, 0.0), currentDepth - bias));
	float su = texture(shadowCanvas, vec3(projCoords.xy + vec2(0.0, -texelSize.y), currentDepth - bias));
	float sd = texture(shadowCanvas, vec3(projCoords.xy + vec2(0.0, texelSize.y), currentDepth - bias));
	float shadow = min(s0, min(sl, min(sr, min(su, sd))));
	
	return shadow;
}





void effect() {

	vec4 color = VaryingColor; // argument 'color' doesn't exist when using multiple canvases, so use built-in VaryingColor

	// these kinds of meshes aren't instanced as they'll all have a unique shape anyway. And it also simplifies the scene management code a lot
	color = vec4(color.x * meshColor.x, color.y * meshColor.y, color.z * meshColor.z, 1.0);
	
	

	// calculate surface normal, used in the shadow map
	// calculate surface normal using interpolated vertex normal and derivative wizardry
	vec3 dp1 = dFdx(fragWorldPosition); // also re-used for the normal map below
	vec3 dp2 = dFdy(fragWorldPosition);
	vec3 surfaceNormal = normalize(cross(dp1, dp2));
	if (dot(surfaceNormal, fragWorldNormal) < 0.0) {
		surfaceNormal = -surfaceNormal;
	}

	// unpack textures for sampling
	vec2 uv = VaryingTexCoord.xy;

	// apply distortion to sampling
	vec2 tex_dist_coords = uv + vec2(-waterVelocity.z, waterVelocity.w) * currentTime;
	vec4 mainData = Texel(dataMap, tex_dist_coords); // r&g = distortion direction, b = foam noise map, a = foaminess

	float distortAngle = mainData.x * 6.28319; // map range [0-1] to [0-2pi]
	float distortScalar = mainData.y;
	vec2 distortion = vec2(cos(distortAngle), sin(distortAngle)) * distortScalar;
	vec2 sampleCoordsWater = uv + distortion + vec2(-waterVelocity.x, waterVelocity.y) * currentTime;
	vec2 sampleCoordsFoam1 = uv + distortion + vec2(-foamVelocity.x, foamVelocity.y) * currentTime;
	vec2 sampleCoordsFoam2 = uv + distortion + vec2(-foamVelocity.z, foamVelocity.w) * currentTime;
	vec4 texColor = Texel(MainTex, sampleCoordsWater);

	// if foam, overwrite texture color
	float foam1Value = Texel(dataMap, sampleCoordsFoam1).z;
	float foam2Value = Texel(dataMap, sampleCoordsFoam2 + vec2(0.5, 0.5)).z;
	float foaminess = Texel(dataMap, uv).a;
	// weird formula to ensure that the chances of f(x,y) > g(x,z) is equal to 'x' where x, y and z are in [0-1] and y&z are uniformally random numbers
	// in other words, if foaminess = 0.3, roughly 30% of pixels become foam, despite doing a greater than comparison a>b.
	if (foaminess == 1 || pow(foam1Value, 1/foaminess) > pow(foam2Value, 1 / (1 - foaminess))) {
	//if (foam1Value < foam2Value + (foaminess - 1.5)) {
		texColor = vec4(foamColor.xyz, 1.0);
	}



	// ended up implementing a very basic naive additive lighting system because it doesn't have any weird edge-cases
	vec3 lighting = ambientColor; // start with just ambient lighting on the surface


	// apply sun-light if not in shadow (from shadow map)
	
	if (shadowsEnabled) {
		float shadow = calculateShadow(fragPosLightSpace, surfaceNormal);
		float sunFactor = max(dot(-fragWorldNormal, sunDirection), 0.0);
		lighting += sunColor * (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5)); // this was 1.0-sunFactor before but that didn't work well for normal maps idk why
	}
	

	// calculate fresnel
	float fresnel = pow(1.0 - max(dot(fragNormal, vec3(0.0, 0.0, 1.0)), 0.0), meshFresnel.y) * meshFresnel.x; // fragNormal is in view-space, meshFresnel: x = strength, y = power

	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = mix(texColor * color, vec4(meshFresnelColor, 1.0), fresnel)
		* (vec4(lighting.x, lighting.y, lighting.z, 1.0) * (1.0 - meshBrightness) + vec4(1.0, 1.0, 1.0, 1.0) * meshBrightness);
	love_Canvases[0] = vec4(resultingColor.xyz, 1.0);//vec4(resultingColor.xyz, 1.0) * 0.01 + 0.01 * vec4(1.0, 0.0, 0.0, 1.0) + 0.98 * col;// * 0.0001 + 0.9999 * vec4(fragWorldNormal * 0.5 + 0.5, 1.0);
	//love_Canvases[1] = vec4(fragNormal.x / 2 + 0.5, fragNormal.y / 2 + 0.5, fragNormal.z / 2 + 0.5, 1.0);

	// apply bloom to canvas
	// this is canvas 2 because 1 is the canvas with view-space normals, but we don't use it (but it's still here because un-setting it takes time)
	love_Canvases[2] = vec4(texColor.x * meshBloom, texColor.y * meshBloom, texColor.z * meshBloom, 1.0);
	
}