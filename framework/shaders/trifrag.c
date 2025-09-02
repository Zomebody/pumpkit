
#pragma language glsl3 // I don't remember why I put this here

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragViewNormal; // used for ambient occlusion and fresnel (IS IN SCREEN SPACE)
varying vec3 fragWorldNormal;
varying vec3 fragWorldSurfaceNormal; // used to solve shadow acne
varying vec4 fragPosLightSpace;
varying mat3 TBN; // tangent bitangent normal matrix, calculated in the vertex shder because it's more efficient

uniform float currentTime;
uniform float diffuseStrength;

// uvs
uniform vec2 uvVelocity; // how quckly the UV scrolls on the X and Y axis, usually this equals 0,0

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
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform vec2 shadowCanvasSize;

// colors
uniform vec3 meshColor;
uniform vec3 meshColorShadow;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
uniform float meshTransparency; // how transparent the mesh is
uniform float meshBloom;
uniform vec2 meshFresnel; // x = strength, y = power
uniform vec3 meshFresnelColor; // vec3 since fresnel won't be supporting transparency (but still works on transparent meshes)
varying vec3 instColor;
varying vec3 instColorShadow;


uniform bool isInstanced;

// triplanar texture projection variables
//uniform float triplanarScale;

// textures
uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image meshTexture; // replaces MainTex. Instead of using mesh:setTexture(), they are now passed separately so that a mesh can be reused with different textures on them
uniform Image normalMap;
uniform sampler2DShadow shadowCanvas; // use Image when doing 'basic' sampling. Use sampler2DShadow when you want automatic bilinear filtering (but more prone to shadow acne :<)
varying vec2 texture_coords;



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




// triplanar fragment code is pretty simple
// it's similar to standard fragment shader except the texture coordinates are already calculated (mostly)


void effect() {

	// argument 'color' doesn't exist when using multiple canvases, so use built-in VaryingColor
	vec4 color;
	vec4 shadowColor;
	if (isInstanced) {
		color = vec4(VaryingColor.x * instColor.x, VaryingColor.y * instColor.y, VaryingColor.z * instColor.z, VaryingColor.w);
		shadowColor = vec4(VaryingColor.x * instColorShadow.x, VaryingColor.y * instColorShadow.y, VaryingColor.z * instColorShadow.z, VaryingColor.w);
	} else {
		color = vec4(VaryingColor.x * meshColor.x, VaryingColor.y * meshColor.y, VaryingColor.z * meshColor.z, VaryingColor.w);
		shadowColor = vec4(VaryingColor.x * meshColorShadow.x, VaryingColor.y * meshColorShadow.y, VaryingColor.z * meshColorShadow.z, VaryingColor.w);
	}
	
	
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	
	
	// sample color map and normal map
	float normalStrength = 1.0;
	vec4 texColor = Texel(meshTexture, texture_coords) * vec4(1.0, 1.0, 1.0, 1.0 - meshTransparency);
	vec3 sampledNormal = Texel(normalMap, texture_coords).rgb * 2.0 - 1.0;
	sampledNormal = normalize(mix(vec3(0.0, 0.0, 1.0), sampledNormal, normalStrength));
	vec3 normalMapNormalWorld = normalize(TBN * sampledNormal);
	
	
	
	// check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01 && meshFresnel.x <= 0.0) {
		discard;  // discard fully transparent pixels
	}

	
	// choose object color depending on if you're in the shadow or in sunlight
	vec4 objectColor = color;

	// if no shadows, keep the mesh color, otherwise tween towards shadow color depending on how much the object is in a shadow
	if (shadowsEnabled) {
		float shadow = calculateShadow(fragPosLightSpace, fragWorldSurfaceNormal); // fragWorldNormal // fragWorldSurfaceNormal
		float sunFactor = max(dot(-normalMapNormalWorld, sunDirection), 0.0); // please don't ask me why * vec3(1.0, 1.0, -1.0) works... I'm super confused
		float mixFactor = (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5));
		objectColor = mix(shadowColor, color, mixFactor);
	}



	// ended up implementing a very basic naive additive lighting system because it doesn't have any weird edge-cases
	vec3 lighting = ambientColor; // start with just ambient lighting on the surface

	// add the lighting contribution of all lights to the surface
	for (int i = 0; i < lightCount; ++i) { // reducing lights from 16 to 1 will only really improve FPS from 235 to 245, so having 16 lights is fine
		Light light = getLight(i);
		
		vec3 lightDir = normalize(light.position - fragWorldPosition);
		float distance = length(light.position - fragWorldPosition);
		float attenuation = clamp(1.0 - pow(distance / light.range, 1.0), 0.0, 1.0);

		// diffuse shading
		float diffuseFactor = max(dot(normalMapNormalWorld, lightDir), 0.0);
		//diffuseFactor = pow(diffuseFactor, 0.5);
		vec3 lightingToAdd = light.color * light.strength * attenuation;
		// if diffStrength == 0, just add the color, otherwise, add based on angle between surface and light direction
		lighting += lightingToAdd * ((diffuseFactor * diffuseStrength) + (1.0 - diffuseStrength)); // if a mesh is fully bright, diffuse strength becomes 0 so that it has no efect
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


	// calculate fresnel
	float fresnel = pow(1.0 - max(dot(fragViewNormal, vec3(0.0, 0.0, 1.0)), 0.0), meshFresnel.y) * meshFresnel.x; // fragViewNormal is in view-space, meshFresnel: x = strength, y = power
	// dumb fix for pow(0,0) stuff. There are probably better solutions
	if (isinf(fresnel) || isnan(fresnel)) {
		fresnel = 0.0;
	}
	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = mix(texColor * objectColor, vec4(meshFresnelColor, 1.0), fresnel); // mix color towards fresnel color
	vec4 resultingLighting = mix(vec4(lighting.xyz, 1.0), vec4(1.0, 1.0, 1.0, 1.0), meshBrightness); // mix lighting based on mesh brightness
	resultingColor = resultingColor * resultingLighting;


	// debug normal maps. This shows fragment normals in world-space
	//resultingColor = resultingColor * 0.00001 + vec4((normalMapNormalWorld.xyz + vec3(1.0)) / 2.0, 1.0);
	love_Canvases[0] = resultingColor;

	love_Canvases[1] = vec4(fragViewNormal.x / 2 + 0.5, fragViewNormal.y / 2 + 0.5, fragViewNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format, alpha = apply ambient occlusion

	// apply bloom to canvas. Semi-transparent meshes will emit weaker bloom
	love_Canvases[2] = vec4(color.x * meshBloom, color.y * meshBloom, color.z * meshBloom, 1.0 - meshTransparency);
	

}


