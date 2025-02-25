

//uniform Image dep


//uniform float radius; // in pixels
const float radius = 6;
const float depthTolerance = 0.003;
uniform vec2 blurDirection;
uniform Image depthTexture;
uniform vec2 screenSize;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 texelSize = blurDirection / screenSize;
	float curDepth = Texel(depthTexture, texture_coords).r;
	vec4 sum = vec4(0.0);
	float totalWeight = 0.0;

	for (float i = -radius; i <= radius; i++) {
		vec2 offset = i * texelSize;
		vec2 sampleCoords = texture_coords + offset;

		float sampleDepth = Texel(depthTexture, sampleCoords).r;
		float depthDifference = abs(sampleDepth - curDepth);

		// Skip samples too far in depth
		if (depthDifference > depthTolerance) continue;

		float spatialWeight = exp(-0.5 * (i / radius) * (i / radius));
		float depthWeight = exp(-0.5 * (depthDifference / depthTolerance) * (depthDifference / depthTolerance));
		float weight = spatialWeight * depthWeight;

		sum += Texel(texture, sampleCoords) * weight;
		totalWeight += weight;
	}

	return sum / totalWeight;
}



