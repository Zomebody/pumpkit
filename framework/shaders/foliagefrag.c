
#pragma language glsl3 // I don't remember why I put this here

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragNormal; // used for normal map
varying vec3 fragWorldNormal;
varying vec4 fragPosLightSpace;

uniform float diffuseStrength;

// lights
struct Light {
	vec3 position;
	vec3 color;
	float range;
	float strength;
};
uniform vec4 lightsInfo[16 * 2]; // array where each even index is {posX, posY, posZ, range} and each uneven index is {colR, colG, colB, strength}
uniform int lightCount;
uniform vec3 ambientColor;

// blob shadows
uniform vec4 blobShadows[16]; // xyz = position, w = range
uniform int blobShadowCount;
uniform vec3 blobShadowColor;
uniform float blobShadowStrength;

// shadow map properties
uniform vec3 sunColor = vec3(0.0); // used to brighten fragments that are lit by the sun
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform vec2 shadowCanvasSize;

// colors
//uniform vec3 meshColor;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
//uniform float meshTransparency; // how transparent the mesh is
//uniform float meshBloom;
varying vec3 instColor;


// textures
uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image meshTexture; // replaces MainTex. Instead of using mesh:setTexture(), they are now passed separately so that a mesh can be reused with different textures on them
uniform Image normalMap;
uniform sampler2DShadow shadowCanvas; // use Image when doing 'basic' sampling. Use sampler2DShadow when you want automatic bilinear filtering (but more prone to shadow acne :<)


// fragment shader


Light getLight(int index) {
	Light light;
	light.position = lightsInfo[index * 2].xyz;
	light.range = lightsInfo[index * 2].w;
	light.color = lightsInfo[index * 2 + 1].xyz;
	light.strength = lightsInfo[index * 2 + 1].w;
	return light;
}


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
	color = vec4(color.x * instColor.x, color.y * instColor.y, color.z * instColor.z, color.w);
	
	
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	

	// calculate surface normal using interpolated vertex normal and derivative wizardry
	vec3 dp1 = dFdx(fragWorldPosition); // also re-used for the normal map below
	vec3 dp2 = dFdy(fragWorldPosition);
	vec3 surfaceNormal = normalize(cross(dp1, dp2));
	if (dot(surfaceNormal, fragWorldNormal) < 0.0) {
		surfaceNormal = -surfaceNormal;
	}
	

	// sample the pixel to display from the supplied texture. For triplanar projection: use world coordinates and surface normal to sample. For regular meshes, use uv coordinates and uvvelocity
	vec2 texture_coords = VaryingTexCoord.xy;
	vec4 texColor = Texel(meshTexture, texture_coords);
	
	// check if the alpha of the texture color is below a threshold
	//if (texColor.a < 0.95 && meshFresnel.x <= 0.0) {
	//	discard;  // discard fully transparent pixels
	//}

	// sample normal map & apply normal map strength
	vec3 sampledNormal = Texel(normalMap, texture_coords).rgb * 2.0 - 1.0;
	float normalStrength = 1.0;
	sampledNormal = normalize(mix(vec3(0.0, 0.0, 1.0), sampledNormal, normalStrength));
	// calculate TBN for normal map lighting stuff
	vec2 duv1 = dFdx(texture_coords);
	vec2 duv2 = dFdy(texture_coords);
	vec3 tangent = normalize(dp1 * duv2.y - dp2 * duv1.y);
	vec3 bitangent = normalize(cross(surfaceNormal, tangent));

	mat3 TBN = mat3(-tangent, -bitangent, fragWorldNormal);
	vec3 normalMapNormal = normalize(TBN * sampledNormal); // in world-space


	// the second canvas is the normals canvas. Output the surface normal to this canvas
	//love_Canvases[1] = vec4(fragNormal.x / 2 + 0.5, fragNormal.y / 2 + 0.5, fragNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format


	// ended up implementing a very basic naive additive lighting system because it doesn't have any weird edge-cases
	vec3 lighting = ambientColor; // start with just ambient lighting on the surface

	// add the lighting contribution of all lights to the surface
	for (int i = 0; i < lightCount; ++i) { // reducing lights from 16 to 1 will only really improve FPS from 235 to 245, so having 16 lights is fine
		Light light = getLight(i);
		
		vec3 lightDir = normalize(light.position - fragWorldPosition);
		float distance = length(light.position - fragWorldPosition);
		float attenuation = clamp(1.0 - pow(distance / light.range, 1.0), 0.0, 1.0);

		// diffuse shading
		float diffuseFactor = max(dot(normalMapNormal, lightDir), 0.0);
		//diffuseFactor = pow(diffuseFactor, 0.5);
		vec3 lightingToAdd = light.color * light.strength * attenuation;
		// if diffStrength == 0, just add the color, otherwise, add based on angle between surface and light direction
		lighting += lightingToAdd * ((diffuseFactor * diffuseStrength) + (1.0 - diffuseStrength)); // if a mesh is fully bright, diffuse strength becomes 0 so that it has no efect
	}


	// apply sun-light if not in shadow (from shadow map)
	if (shadowsEnabled) {
		float shadow = calculateShadow(fragPosLightSpace, surfaceNormal);
		float sunFactor = max(dot(-normalMapNormal, sunDirection), 0.0); // please don't ask me why * vec3(1.0, 1.0, -1.0) works... I'm super confused
		//lighting += sunColor * (1.0 - shadow * shadowStrength) * (1.0 - sunFactor);
		lighting += sunColor * (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5)); // this was 1.0-sunFactor before but that didn't work well for normal maps idk why
	}


	// apply blob-shadow
	float maxShadowFactor = 0.0;
	for (int i = 0; i < blobShadowCount; ++i) {
		vec3 blobPosition = blobShadows[i].xyz;
		float blobRange = blobShadows[i].w;
		float distance = length(blobPosition - fragWorldPosition);
		float x = distance / blobRange;
		float shadowFactor = 1.0 - clamp(x * x * x, 0.0, 1.0);
		shadowFactor *= blobShadowStrength;
		maxShadowFactor = max(maxShadowFactor, shadowFactor);
	}
	lighting = mix(lighting, blobShadowColor, maxShadowFactor);

	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = texColor * color * mix(vec4(lighting.x, lighting.y, lighting.z, 1.0), vec4(1.0, 1.0, 1.0, 1.0), meshBrightness);

	// moved discarding all the way down here
	// why? because for some reason black outlines appear otherwise. I don't know why, but this fixes it
	// but is it bad to discard later rather than early? Probably! But at least this fixes it
	if (resultingColor.a < 0.95) {
		discard;  // discard pixels with at least some transparency
	}

	love_Canvases[0] = resultingColor;// * 0.0001 + 0.9999 * vec4(fragWorldNormal * 0.5 + 0.5, 1.0);

	love_Canvases[1] = vec4(fragNormal.x / 2 + 0.5, fragNormal.y / 2 + 0.5, fragNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format

	// apply bloom to canvas. Semi-transparent meshes will emit weaker bloom
	//love_Canvases[2] = vec4(color.x * meshBloom, color.y * meshBloom, color.z * meshBloom, 1.0 - meshTransparency);
	

}


