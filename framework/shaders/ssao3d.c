#pragma language glsl3

uniform mat4 perspectiveMatrix;
uniform mat4 invPerspectiveMatrix;
uniform mat4 camMatrix;

uniform float aoStrength;
uniform float kernelScalar;
//uniform float viewDistanceFactor;
uniform int samples; // higher samples = less noisy ambient occlusion

uniform Image noiseTexture; // assumed to be a 16x16 noise texture where r,g,b = x,y,z normal vector with z>0

const float rangeCheckScalar = 20.0; // larger value == need to zoom out further for AO to fade away


const vec3 samplingKernel[24] = vec3[](
	/*
	// 0.25x quality
	vec3(-0.797, -0.764, 3.68) / 5.5,
	vec3(-3.853, 0.547, 1.216) / 5.5,
	vec3(-1.309, 0.448, 1.803) / 5.5,
	vec3(-1.106, 3.985, 0.869) / 5.5,
	vec3(2.68, 2.919, 2.745) / 5.5,
	vec3(1.481, 1.68, 4.456) / 5.5,
	vec3(2.302, -0.194, 2.517) / 5.5,
	vec3(0.983, -3.108, 0.527) / 5.5,
	
	// added at 0.5x quality
	vec3(0.632, -0.194, 0.546) / 5.5,
	vec3(1.672, 2.659, 0.424) / 5.5,
	vec3(-2.454, -1.056, 1.524) / 5.5,
	vec3(-0.105, -2.043, 3.335) / 5.5,
	vec3(2.595, -1.503, 0.735) / 5.5,
	vec3(-1.445, -3.858, 1.08) / 5.5,
	vec3(-0.449, 2.331, 3.651) / 5.5,
	vec3(-1.973, 2.37, 2.144) / 5.5,

	// added at 1x quality
	vec3(-0.333, -1.122, 0.207) / 5.5,
	vec3(0.174, -3.858, 1.766) / 5.5,
	vec3(-4.082, -1.473, 2.565) / 5.5,
	vec3(0.745, 4.287, 1.677) / 5.5,
	vec3(2.092, -2.043, 3.483) / 5.5,
	vec3(-2.681, 1.279, 1.703) / 5.5,
	vec3(0.275, 1.058, 3.025) / 5.5,
	vec3(3.379, 0.861, 1.175) / 5.5
	*/

	vec3(0.677, 1.156, 1.657) / 3.0,
	vec3(-0.482, -0.006, 2.874) / 3.0,
	vec3(-1.584, 0.518, 0.381) / 3.0,
	vec3(1.921, -1.066, 1.289) / 3.0,
	vec3(-0.285, -0.289, 0.849) / 3.0,
	vec3(-1.407, -1.316, 0.557) / 3.0,
	vec3(-0.541, 1.916, 0.575) / 3.0,
	vec3(0.781, -0.946, 0.224) / 3.0,

	vec3(0.949, 1.436, 0.882) / 3.0,
	vec3(-0.039, 0.369, 0.252) / 3.0,
	vec3(0.070, -1.155, 0.185) / 3.0,
	vec3(2.455, 0.037, 1.373) / 3.0,
	vec3(-1.191, -2.206, 0.727) / 3.0,
	vec3(0.763, 0.037, 0.501) / 3.0,
	vec3(-1.678, 1.436, 1.476) / 3.0,
	vec3(0.249, 0.037, 1.825) / 3.0,

	vec3(-0.762, 0.516, 0.995) / 3.0,
	vec3(-0.480, -0.499, 0.265) / 3.0,
	vec3(0.600, -1.991, 1.779) / 3.0,
	vec3(1.260, 0.516, 0.335) / 3.0,
	vec3(-0.053, -0.954, 1.058) / 3.0,
	vec3(1.384, -0.667, 0.718) / 3.0,
	vec3(-1.153, -0.443, 1.493) / 3.0,
	vec3(-0.087, 2.333, 1.132) / 3.0
);




float calculateOcclusion(vec3 fragmentPos, vec3 normal, vec2 texCoord, Image depthTexture) {

	// calculate a matrix that will transform a normal vector from world-space to surface-space
	vec3 up = abs(normal.y) < 0.999 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangent = normalize(cross(up, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 TBN = mat3(tangent, bitangent, normal); // transforms a vector from world-space to the surface normal space

	vec2 noiseSamplePosition = vec2(
		float(love_PixelCoord.x) / 8.0,
		float(love_PixelCoord.y) / 8.0
	);

	float sampledRotation = Texel(noiseTexture, noiseSamplePosition).r * 6.283; // sample a rotation for this pixel from the noise texture
	float cosAngle = cos(sampledRotation);
	float sinAngle = sin(sampledRotation);

	float occlusion = 0.0;


	for (int i = 0; i < samples; i++) { // loop through each item in samplingKernel
		// grab the vec3 from the kernel and rotate it around the surface normal by some factor sampled from the noise texture
		//vec3 kernelVector = rotateKernelVector(samplingKernel[i], sampledRotation);
		vec3 kernelVector = vec3(
			samplingKernel[i].x * cosAngle - samplingKernel[i].y * sinAngle,
			samplingKernel[i].x * sinAngle + samplingKernel[i].y * cosAngle,
			samplingKernel[i].z
		);

		vec3 worldSampleDir = TBN * kernelVector * kernelScalar; // for the current index in the kernel, calculate where it's pointing in world-space when placed on the mesh's surface
		vec3 sampleWorldPos = fragmentPos + worldSampleDir; // offset sample in world space

		// project sample position to screen space
		vec4 sampleScreenPos = perspectiveMatrix * vec4(sampleWorldPos, 1.0);
		sampleScreenPos /= sampleScreenPos.w; // perspective divide
		vec2 sampleTexCoord = sampleScreenPos.xy * 0.5 + 0.5; // map to [0, 1]

		float sampleDepth = Texel(depthTexture, sampleTexCoord).r;
		vec4 sampledFragmentWorldPos = invPerspectiveMatrix * vec4(sampleScreenPos.xy, sampleDepth, 1.0);
		sampledFragmentWorldPos /= sampledFragmentWorldPos.w;

		// compare depths to check for occlusion
		// these two lines were stolen from: https://learnopengl.com/Advanced-Lighting/SSAO
		if (sampledFragmentWorldPos.z > sampleWorldPos.z) { // check if the fragment at a the sampled screen coordinate is in front of a random sampled ambient point near the surface we're evaluating
			
			// let's spice this occlusion checker up a bit. We'll calculate a rangeCheck variable that will make ambient occlusion less intense as you zoom out
			// we'll also calculate a value that checks the *world space* distance between our surface point and the sampled nearby (occluded) point. As the gap between them grows, make occlusion less intense
			// for this gap we can re-use the kernelScalar value!
			
			float rangeCheck = smoothstep(0.0, 1.0, rangeCheckScalar / abs(fragmentPos.z - sampleDepth));
			float gapSize = sampledFragmentWorldPos.z - sampleWorldPos.z;
			float clampedScaledGap = clamp(1.0 - gapSize * kernelScalar, 0.0, 1.0);
			float darkenFactor = clampedScaledGap * clampedScaledGap * clampedScaledGap; // pow(clampedScaledGap, 3)

			occlusion += darkenFactor * rangeCheck;
		}
	}

	return occlusion / float(samples); // float(sampleSize) // (sampleSize = 16) normalize occlusion
}






uniform Image normalTexture;


vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoords) {
	float depth = Texel(tex, texCoord).r;
	if (depth == 1.0) {
		return vec4(1.0); // no occlusion in empty space
	}



	// reconstruct world position
	vec4 screenPos = vec4(texCoord * 2.0 - 1.0, depth, 1.0);
	//mat4 invPerspectiveMatrix = inverse(perspectiveMatrix);
	vec4 worldPos = invPerspectiveMatrix * screenPos;
	worldPos /= worldPos.w;

	// get normal (relative to the screen) from normal texture
	vec3 normal = Texel(normalTexture, texCoord).rgb * 2.0 - 1.0;

	// calculate ambient occlusion
	float occlusion = calculateOcclusion(worldPos.xyz, normal, texCoord, tex);

	return vec4(vec3(1.0 - occlusion * aoStrength), 1.0); // darken by occlusion amount

}


