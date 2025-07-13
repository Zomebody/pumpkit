
#pragma language glsl3

varying vec4 fragPosLightSpace;

uniform Image MainTex;

uniform Image dataTexture; // data texture containing (currently) the color gradient and size curve
uniform float currentTime;
uniform float brightness;
uniform vec2 flipbookData; // x = size, y = frame count (in reading order)


varying float emittedAt;
varying float lifetime;
varying vec3 fragWorldPosition;
varying vec3 fragWorldNormal;
uniform bool blends;

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


// shadow map properties
uniform vec3 sunColor = vec3(0.0); // used to brighten fragments that are lit by the sun
uniform float shadowStrength; // used to make shadows more/less intense
uniform vec3 sunDirection;
uniform bool shadowsEnabled = false;
uniform sampler2DShadow shadowCanvas;



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
// simpler version as we don't need to care about bias since particles are never 'on' a surface
/*
float calculateShadow() {
	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// no shadows when outside the shadow canvas
	if (projCoords.x < 0.0 || projCoords.x > 1.0 || projCoords.y < 0.0 || projCoords.y > 1.0) {
		return 0.0;
	}



	float s = texture(shadowCanvas, vec3(projCoords.xy, projCoords.z));
	
	return s;
}
*/

float calculateShadow() {
	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
	projCoords = projCoords * 0.5 + 0.5;

	// no shadows when outside the shadow canvas
	if (projCoords.x < 0.0 || projCoords.x > 1.0 || projCoords.y < 0.0 || projCoords.y > 1.0) {
		return 0.0;
	}

	float s = texture(shadowCanvas, vec3(projCoords.xy, projCoords.z));
	
	return s;
}



// fragment shader
void effect() {
	float ageFraction = (currentTime - emittedAt) / lifetime;
	if (ageFraction > 1) {
		discard;
	}

	// sample the gradient color from the top row of the data texture
	float gradientU = clamp(ageFraction, 0.0, 1.0); // Ensure it stays within the range [0, 1]
	vec2 gradientUV = vec2(gradientU, 0.25); // Top row (assume 2-pixel tall texture, so Y = 0.25 for the top row)
	vec4 gradientColor = Texel(dataTexture, gradientUV);

	// sample from texture using flipbook data. If default flipbook properties are used, this is equal to just sampling from a static image
	float flipbookSize = flipbookData.x;
	float flipbookFrames = flipbookData.y;
	float curFrame = floor(ageFraction * flipbookFrames);
	float frameX = mod(curFrame, flipbookSize);
	float frameY = mod(floor(curFrame / flipbookSize), flipbookSize);
	vec2 cellSize = vec2(1.0 / flipbookSize);
	vec2 sampleUV = VaryingTexCoord.xy * cellSize + vec2(frameX, frameY) * cellSize;
	vec4 texColor = Texel(MainTex, sampleUV);

	// check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01) {
		discard;  // Discard fully transparent pixels
	}




	vec3 lighting = ambientColor; // start with just ambient lighting on the surface
	//float totalInfluence = 0;

	// add the lighting contribution of all lights to the surface
	for (int i = 0; i < lightCount; ++i) {
		Light light = getLight(i);
		//if (light.strength > 0) { // only consider lights with a strength above 0
		// distance to the light
		float distance = length(light.position - fragWorldPosition);
		// attenuation factor
		float attenuation = clamp(1.0 - pow(distance / light.range, 1), 0.0, 1.0);
		// sum up the light contributions
		lighting += light.color * light.strength * attenuation;
		//}
	}


	// apply sun-light if not in shadow (from shadow map)
	if (shadowsEnabled) {
		float shadow = calculateShadow();
		float sunFactor = max(dot(-fragWorldNormal, sunDirection), 0.0);
		//float sunFactor = 1.0 + sunDirection.x * 0.0001;//1.0; // TODO: calc using particle's facing direction
		lighting += sunColor * (1.0 - shadow * shadowStrength) * (pow(sunFactor, 0.5)); // this was 1.0-sunFactor before but that didn't work well for normal maps idk why
	}


	vec4 litColor = (texColor * gradientColor) * brightness + (texColor * gradientColor * vec4(lighting.x, lighting.y, lighting.z, 1.0)) * (1.0 - brightness);

	// if the particle has 'blends' set to true, start accumulating colors onto the canvas with some maths
	// however, if the particle has 'blends' set to false, simply just draw the particle color
	if (blends) {
		// in this case, blend mode is set to additive and two canvases are used (ParticleCanvas1, ParticleCanvas2)
		love_Canvases[0] = vec4(litColor.r * litColor.a, litColor.g * litColor.a, litColor.b * litColor.a, 1.0); // Q: why not store alpha here? A: docs says thet blend mode 'add': The alpha of the screen is not modified, hence moved to other canvas
		// for red, simply add '1' to red to count the number of fragments being written
		// for green, square the alpha to give a higher priority 
		//love_Canvases[1] = vec4(1.0, pow(litColor.a, 2.0), 0.0, 1.0);
		love_Canvases[1] = vec4(1.0, litColor.a, 1.0, 1.0);
	} else {
		// in this case, blend mode is set to the default (alpha) one and the output canvase is the RenderCanvas
		love_Canvases[0] = litColor;
	}

}
