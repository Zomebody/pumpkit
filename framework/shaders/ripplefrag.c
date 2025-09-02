
#pragma language glsl3 // I don't remember why I put this here

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragViewNormal; // used for ambient occlusion and fresnel (IS IN SCREEN SPACE)
varying vec3 fragWorldNormal;
varying vec3 fragWorldSurfaceNormal; // used to solve shadow acne
varying vec4 fragPosLightSpace;

uniform float currentTime;
uniform vec3 ambientColor;

// shadow map properties
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform vec2 shadowCanvasSize;

// colors
uniform vec3 meshColor;
uniform vec3 meshColorShadow;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
uniform float meshBloom;
uniform vec2 meshFresnel; // x = strength, y = power
uniform vec3 meshFresnelColor; // vec3 since fresnel won't be supporting transparency (but still works on transparent meshes)

// textures
//uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image meshTexture; // replaces MainTex. Instead of using mesh:setTexture(), they are now passed separately so that a mesh can be reused with different textures on them
//uniform Image normalMap; // unused, might be implemented later down the line idk
uniform Image dataMap; // rg = distortion (angle & scalar), b = noise value for foam, a = foaminess (0 = no foam)
uniform vec3 foamColor; // xyz = color
uniform vec3 foamColorShadow;
uniform float foamInShadow;
uniform sampler2DShadow shadowCanvas; // use Image when doing 'basic' sampling. Use sampler2DShadow when you want automatic bilinear filtering (but more prone to shadow acne :<)
uniform vec4 waterVelocity; // x&y = water velocity, z&w = distortion velocity
uniform vec4 foamVelocity; // two directions & speeds at which the foams move





// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
// calculate shadow using sampler2DShadow, which uses bilinear filtering automatically for better shadows, but has bigger problems with shadow acne :<

float calculateShadow(vec4 fragPosLightSpace, vec3 surfaceNormalWorld) {
	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// no shadows when outside the shadow canvas
	if (projCoords.x < 0.0 || projCoords.x > 1.0 || projCoords.y < 0.0 || projCoords.y > 1.0) {
		return 0.0;
	}

	float currentDepth = projCoords.z;

	// bias calc taken from: http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/#aliasing
	float cosTheta = clamp(dot(surfaceNormalWorld, sunDirection), 0.0, 1.0);
	float bias = 0.00025 * tan(acos(cosTheta)); // cosTheta is dot( n,l ), clamped between 0 and 1
	bias = clamp(bias, 0, 0.00025); // used to be 0.005, but lowered because neighbor sampling works perfectly with reducing acne
	

	// sample depth at own position, but also sample 4 neighbors
	// is a pretty alright solution to shadow acne, but might be a bit slow
	
	vec2 texelSize = 1.0 / shadowCanvasSize;
	float s0 = texture(shadowCanvas, projCoords + vec3(0.0, 0.0, -bias));
	float sl = texture(shadowCanvas, projCoords + vec3(-texelSize.x, 0.0, -bias));
	float sr = texture(shadowCanvas, projCoords + vec3(texelSize.x, 0.0, -bias));
	float su = texture(shadowCanvas, projCoords + vec3(0.0, -texelSize.y, -bias));
	float sd = texture(shadowCanvas, projCoords + vec3(0.0, texelSize.y, -bias));
	
	float shadow = min(s0, min(sl, min(sr, min(su, sd))));
	
	return shadow;
}





void effect() {

	// these kinds of meshes aren't instanced as they'll all have a unique shape anyway. And it also simplifies the scene management code a lot
	vec4 color = vec4(VaryingColor.x * meshColor.x, VaryingColor.y * meshColor.y, VaryingColor.z * meshColor.z, 1.0);
	vec4 shadowColor = vec4(VaryingColor.x * meshColorShadow.x, VaryingColor.y * meshColorShadow.y, VaryingColor.z * meshColorShadow.z, color.w);
	

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
	//vec4 texColor = Texel(MainTex, sampleCoordsWater);
	vec4 texColor = Texel(meshTexture, sampleCoordsWater);

	// if foam, overwrite texture color
	float foam1Value = Texel(dataMap, sampleCoordsFoam1).z;
	float foam2Value = Texel(dataMap, sampleCoordsFoam2 + vec2(0.5, 0.5)).z;
	float foaminess = Texel(dataMap, uv).a;


	// start with just ambient lighting on the surface
	vec3 lighting = ambientColor;

	// choose object color depending on if you're in the shadow or in sunlight
	vec4 objectColor = color;

	// apply sun-light if not in shadow (from shadow map)
	// 1 when in shadow, 0 when in sun
	float shadow = 1.0;
	if (shadowsEnabled) {
		shadow = calculateShadow(fragPosLightSpace, fragWorldSurfaceNormal); // fragWorldNormal // fragWorldSurfaceNormal
		float sunFactor = max(dot(-fragWorldNormal, sunDirection), 0.0); // please don't ask me why * vec3(1.0, 1.0, -1.0) works... I'm super confused
		//float mixFactor = 1.0 - shadow * shadowStrength * pow(sunFactor, 0.5);
		float mixFactor = (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5));
		objectColor = mix(shadowColor, color, mixFactor);
	}


	// weird formula to ensure that the chances of f(x,y) > g(x,z) is equal to 'x' where x, y and z are in [0-1] and y&z are uniformally random numbers
	// in other words, if foaminess = 0.3, roughly 30% of pixels become foam, despite doing a greater than comparison a>b.
	if (foaminess == 1 || pow(foam1Value, 1/foaminess) > pow(foam2Value, 1 / (1 - foaminess))) {
		float blend = mix(1.0, foamInShadow, shadow);
		vec3 mixedFoamColor = mix(foamColor, foamColorShadow, shadow);
		texColor = mix(texColor, vec4(mixedFoamColor, 1.0), blend);
	}
	

	// calculate fresnel
	float fresnel = pow(1.0 - max(dot(fragViewNormal, vec3(0.0, 0.0, 1.0)), 0.0), meshFresnel.y) * meshFresnel.x; // fragViewNormal is in view-space, meshFresnel: x = strength, y = power

	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = mix(texColor * objectColor, vec4(meshFresnelColor, 1.0), fresnel); // mix color towards fresnel color
	vec4 resultingLighting = mix(vec4(lighting.xyz, 1.0), vec4(1.0, 1.0, 1.0, 1.0), meshBrightness); // mix lighting based on mesh brightness
	resultingColor = resultingColor * resultingLighting;

	love_Canvases[0] = vec4(resultingColor.xyz, 1.0);//vec4(resultingColor.xyz, 1.0) * 0.01 + 0.01 * vec4(1.0, 0.0, 0.0, 1.0) + 0.98 * col;// * 0.0001 + 0.9999 * vec4(fragWorldNormal * 0.5 + 0.5, 1.0);
	//love_Canvases[1] = vec4(fragViewNormal.x / 2 + 0.5, fragViewNormal.y / 2 + 0.5, fragViewNormal.z / 2 + 0.5, 1.0);

	love_Canvases[1] = vec4(fragViewNormal.x / 2 + 0.5, fragViewNormal.y / 2 + 0.5, fragViewNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format

	// apply bloom to canvas
	// this is canvas 2 because 1 is the canvas with view-space normals, but we don't use it (but it's still here because un-setting it takes time)
	love_Canvases[2] = vec4(texColor.x * meshBloom, texColor.y * meshBloom, texColor.z * meshBloom, 1.0);
	
}