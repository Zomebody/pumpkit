

uniform vec2 blurDirection;
uniform float blurSize; // radius in pixels
//uniform float bloomQuality; // either 1.0, 0.5 or 0.25
uniform vec2 screenSize;

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoords) {
	vec4 sumColor = vec4(0.0);
	
	// number of samples (adaptive, based on blur size)
	int samples = int(min(8.0, blurSize)); // number of samples depends on supplied size, clamp when using high blur sizes
	float sumWeight = 0.0;
	
	// apply 1d guassian blur, but skip over pixels when at larger blur sizes to prevent performance drops
	for (int i = -samples; i <= samples; i++) {
		float weight = exp(-0.5 * (float(i) / blurSize) * (float(i) / blurSize)); // Gaussian approximation
		vec2 offset = blurDirection * float(i) * (blurSize / samples) / screenSize; // account for screen resolution to get steps in pixels
		sumColor += Texel(tex, texCoord + offset) * weight;
		sumWeight += weight;
	}

	return sumColor / sumWeight; // normalize to keep bloom intensity similar at higher blur sizes
}
