
#pragma language glsl3 // I don't remember why I put this here

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragNormal; // used for normal map
varying vec3 fragWorldNormal;
varying vec4 fragPosLightSpace;
//varying float fragDistanceToCamera; // used for fog
//varying vec3 cameraViewDirection;

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
uniform vec3 sunColor = vec3(0.0); // used to brighten fragments that are lit by the sun
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform vec2 shadowCanvasSize;

// colors
uniform vec3 meshColor;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
uniform float meshTransparency; // how transparent the mesh is
uniform float meshBloom;
uniform vec2 meshFresnel; // x = strength, y = power
uniform vec3 meshFresnelColor; // vec3 since fresnel won't be supporting transparency (but still works on transparent meshes)
varying vec3 instColor;


uniform bool isInstanced;

// triplanar texture projection variables
uniform float triplanarScale;

// textures
uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image meshTexture; // replaces MainTex. Instead of using mesh:setTexture(), they are now passed separately so that a mesh can be reused with different textures on them
uniform Image normalMap;
uniform sampler2DShadow shadowCanvas; // use Image when doing 'basic' sampling. Use sampler2DShadow when you want automatic bilinear filtering (but more prone to shadow acne :<)

// sprites
uniform vec2 spritePosition;
uniform vec2 spriteSheetSize;
uniform bool isSpriteSheet;


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


	// TODO: when you split the shadowmap into a static and dynamic texture, for sampling the dynamic texture
	// you'll get away with simply taking the above bias and multiplying by a factor 10
	// you'll get worse peter panning but less acne at steep angles
	// and for dynamic geometry / semi-transparent geometry that extra peter panning will be hard to notice anyway!


	// sample depth at own position, but also sample 4 neighbors
	// this seems surprisingly effective and clever but maybe a bit slow?
	
	vec2 texelSize = 1.0 / shadowCanvasSize;
	
	float s0 = texture(shadowCanvas, projCoords + vec3(0.0, 0.0, -bias));
	float sl = texture(shadowCanvas, projCoords + vec3(-texelSize.x, 0.0, -bias));
	float sr = texture(shadowCanvas, projCoords + vec3(texelSize.x, 0.0, -bias));
	float su = texture(shadowCanvas, projCoords + vec3(0.0, -texelSize.y, -bias));
	float sd = texture(shadowCanvas, projCoords + vec3(0.0, texelSize.y, -bias));
	
	float shadow = min(s0, min(sl, min(sr, min(su, sd))));
	//float shadow = min(s0, sl);
	
	return shadow;
}





void effect() {

	vec4 color = VaryingColor; // argument 'color' doesn't exist when using multiple canvases, so use built-in VaryingColor
	if (isInstanced) {
		color = vec4(color.x * instColor.x, color.y * instColor.y, color.z * instColor.z, color.w);
	} else {
		color = vec4(color.x * meshColor.x, color.y * meshColor.y, color.z * meshColor.z, color.w);
	}
	
	
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	

	// calculate surface normal, used in triplanar projection AND in the shadow map, so it gets calculated here
	// calculate surface normal using interpolated vertex normal and derivative wizardry
	vec3 dp1 = dFdx(fragWorldPosition); // also re-used for the normal map below
	vec3 dp2 = dFdy(fragWorldPosition);
	vec3 surfaceNormal = normalize(cross(dp1, dp2));
	if (dot(surfaceNormal, fragWorldNormal) < 0.0) {
		surfaceNormal = -surfaceNormal;
	}
	

	// sample the pixel to display from the supplied texture. For triplanar projection: use world coordinates and surface normal to sample. For regular meshes, use uv coordinates and uvvelocity
	vec4 texColor;
	vec2 texture_coords;
	if (triplanarScale > 0.0) { // project texture onto mesh using triplanar projection

		float absNormX = abs(surfaceNormal.x); // fragWorldNormal
		float absNormY = abs(surfaceNormal.y); // fragWorldNormal
		float absNormZ = abs(surfaceNormal.z); // fragWorldNormal
		if (absNormX > absNormY && absNormX > absNormZ) {
			// pointing into x-direction
			texture_coords = vec2(fragWorldPosition.y * triplanarScale, fragWorldPosition.z * triplanarScale);
			//texColor = vec4(1.0, 0.0, 0.0, 1.0);
		} else if (absNormY > absNormZ) {
			// pointing into y-direction
			texture_coords = vec2(fragWorldPosition.x * triplanarScale, fragWorldPosition.z * triplanarScale);
			//texColor = vec4(0.0, 1.0, 0.0, 1.0);
		} else {
			// pointing into z-direction
			texture_coords = vec2(fragWorldPosition.x * triplanarScale, fragWorldPosition.y * triplanarScale);
			//texColor = vec4(0.0, 0.0, 1.0, 1.0);
		}
	} else if (!isSpriteSheet) { // simply grab the uv coordinates for applying the texture
		texture_coords = VaryingTexCoord.xy; // argument 'texture_coords' doesn't exist when doing multi-canvas operations, so extract it from VaryingTexCoord instead
	} else { // it's a spritesheet, so sample from the right sub-section in the spritesheet
		texture_coords = VaryingTexCoord.xy / spriteSheetSize + spritePosition / spriteSheetSize;
	}
	//texColor = Texel(MainTex, texture_coords - uvVelocity * currentTime) * vec4(1.0, 1.0, 1.0, 1.0 - meshTransparency);
	texColor = Texel(meshTexture, texture_coords - uvVelocity * currentTime) * vec4(1.0, 1.0, 1.0, 1.0 - meshTransparency);
	
	// check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01 && meshFresnel.x <= 0.0) {
		discard;  // discard fully transparent pixels
	}

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
	vec3 normalMapNormalWorld = normalize(TBN * sampledNormal); // in world-space


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
		float diffuseFactor = max(dot(normalMapNormalWorld, lightDir), 0.0);
		//diffuseFactor = pow(diffuseFactor, 0.5);
		vec3 lightingToAdd = light.color * light.strength * attenuation;
		// if diffStrength == 0, just add the color, otherwise, add based on angle between surface and light direction
		lighting += lightingToAdd * ((diffuseFactor * diffuseStrength) + (1.0 - diffuseStrength)); // if a mesh is fully bright, diffuse strength becomes 0 so that it has no efect
	}

	// apply sun-light if not in shadow (from shadow map)
	if (shadowsEnabled) {
		float shadow = calculateShadow(fragPosLightSpace, surfaceNormal);
		float sunFactor = max(dot(-normalMapNormalWorld, sunDirection), 0.0); // please don't ask me why * vec3(1.0, 1.0, -1.0) works... I'm super confused
		//lighting += sunColor * (1.0 - shadow * shadowStrength) * (1.0 - sunFactor);
		lighting += sunColor * (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5)); // this was 1.0-sunFactor before but that didn't work well for normal maps idk why
	}


	// apply blob-shadow onto anything that isn't a spritemesh
	if (!isSpriteSheet) {
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
	}

	// calculate fresnel
	float fresnel = pow(1.0 - max(dot(fragNormal, vec3(0.0, 0.0, 1.0)), 0.0), meshFresnel.y) * meshFresnel.x; // fragNormal is in view-space, meshFresnel: x = strength, y = power
	// dumb fix for pow(0,0) stuff. There are probably better solutions
	if (isinf(fresnel) || isnan(fresnel)) {
		fresnel = 0.0;
	}
	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = mix(texColor * color, vec4(meshFresnelColor, 1.0), fresnel) // mix fresnel with texture color
		* (vec4(lighting.x, lighting.y, lighting.z, 1.0) * (1.0 - meshBrightness) + vec4(1.0, 1.0, 1.0, 1.0) * meshBrightness); // multiply by lighting (& mix with brightness)


	love_Canvases[0] = resultingColor;// * 0.0001 + 0.9999 * vec4(fragWorldNormal * 0.5 + 0.5, 1.0);

	love_Canvases[1] = vec4(fragNormal.x / 2 + 0.5, fragNormal.y / 2 + 0.5, fragNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format, alpha = apply ambient occlusion

	// apply bloom to canvas. Semi-transparent meshes will emit weaker bloom
	love_Canvases[2] = vec4(color.x * meshBloom, color.y * meshBloom, color.z * meshBloom, 1.0 - meshTransparency);
	

}


