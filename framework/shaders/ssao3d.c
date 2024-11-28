// SSAO Shader
//uniform Image depthTexture;

// camera variables
//uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;

const int sampleCount = 16; // Number of samples

const vec3 kernel[sampleCount] = vec3[]( // list of 16 samples. Samples were generated using two fibonacci spheres, one with 12 points with r=1 and one with 4 points with r=0.6
	// first sphere
	vec3(0.0345, 0.0939, 0.0000),
	vec3(-0.0472, 0.0768, -0.0433),
	vec3(0.0070, 0.0597, 0.0799),
	vec3(0.0550, 0.0427, -0.0718),
	vec3(-0.0952, 0.0256, 0.0168),
	vec3(0.0841, 0.0085, 0.0535),
	vec3(-0.0259, -0.0085, -0.0962),
	vec3(-0.0446, -0.0256, 0.0858),
	vec3(0.0850, -0.0427, -0.0310),
	vec3(-0.0741, -0.0597, -0.0306),
	vec3(0.0271, -0.0768, 0.0580),
	vec3(0.0103, -0.0939, -0.0329),
	// second sphere
	vec3(0.0355, 0.0484, 0.0000),
	vec3(-0.0426, 0.0161, -0.0390),
	vec3(0.0051, -0.0161, 0.0576),
	vec3(0.0216, -0.0484, -0.0282)
);



// vertical field-of-view is used
mat4 getPerspectiveMatrix(float fieldOfView, float aspect) {
	float tanHalfFov = tan(fieldOfView / 2.0);

	mat4 perspectiveMatrix = mat4(0.0);
	perspectiveMatrix[0][0] = 1.0 / (aspect * tanHalfFov);
	perspectiveMatrix[1][1] = 1.0 / (tanHalfFov);
	perspectiveMatrix[2][2] = -(zFar + zNear) / (zFar - zNear);
	perspectiveMatrix[2][3] = -1.0;
	perspectiveMatrix[3][2] = -(2.0 * zFar * zNear) / (zFar - zNear);
	perspectiveMatrix[3][3] = 0.0; // chatgpt suggested this for some reason????

	return perspectiveMatrix;
}



mat4 inverse(mat4 m) {
	float
		a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3],
		a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3],
		a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3],
		a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3],

	b00 = a00 * a11 - a01 * a10,
	b01 = a00 * a12 - a02 * a10,
	b02 = a00 * a13 - a03 * a10,
	b03 = a01 * a12 - a02 * a11,
	b04 = a01 * a13 - a03 * a11,
	b05 = a02 * a13 - a03 * a12,
	b06 = a20 * a31 - a21 * a30,
	b07 = a20 * a32 - a22 * a30,
	b08 = a20 * a33 - a23 * a30,
	b09 = a21 * a32 - a22 * a31,
	b10 = a21 * a33 - a23 * a31,
	b11 = a22 * a33 - a23 * a32,

	det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

	if (abs(det) < 0.00001) {
		return mat4(1.0); // If determinant is 0, return identity matrix (or handle however you want)
	}

	float invDet = 1.0 / det;

	return mat4(
		(a11 * b11 - a12 * b10 + a13 * b09) * invDet,
		(a02 * b10 - a01 * b11 - a03 * b09) * invDet,
		(a31 * b05 - a32 * b04 + a33 * b03) * invDet,
		(a22 * b04 - a21 * b05 - a23 * b03) * invDet,
		(a12 * b08 - a10 * b11 - a13 * b07) * invDet,
		(a00 * b11 - a02 * b08 + a03 * b07) * invDet,
		(a32 * b02 - a30 * b05 - a33 * b01) * invDet,
		(a20 * b05 - a22 * b02 + a23 * b01) * invDet,
		(a10 * b10 - a11 * b08 + a13 * b06) * invDet,
		(a01 * b08 - a00 * b10 - a03 * b06) * invDet,
		(a30 * b04 - a31 * b02 + a33 * b00) * invDet,
		(a21 * b02 - a20 * b04 - a23 * b00) * invDet,
		(a11 * b07 - a10 * b09 - a12 * b06) * invDet,
		(a00 * b09 - a01 * b07 + a02 * b06) * invDet,
		(a31 * b01 - a30 * b03 - a32 * b00) * invDet,
		(a20 * b03 - a21 * b01 + a22 * b00) * invDet
	);
}




vec3 reconstructPosition(float depth, vec2 uv) {
	vec4 clipSpace = vec4(uv * 2.0 - 1.0, depth, 1.0);

	mat4 perspectiveMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);
	mat4 invPerspective = inverse(perspectiveMatrix);
	vec4 viewSpace = invPerspective * clipSpace;

	return (viewSpace / viewSpace.w).xyz;
}




float calculateAmbientOcclusion(vec3 fragPos, vec3 normal, Image depthTexture) {
	float occlusion = 0.0;
	for (int i = 0; i < sampleCount; i++) {
		vec3 samplePos = fragPos + kernel[i];
		vec4 sampleProj = getPerspectiveMatrix(fieldOfView, aspectRatio) * vec4(samplePos, 1.0);
		vec2 sampleUV = (sampleProj.xy / sampleProj.w) * 0.5 + 0.5;

		float sampleDepth = Texel(depthTexture, sampleUV).r;
		vec3 sampleWorldPos = reconstructPosition(sampleDepth, sampleUV);

		float dist = length(sampleWorldPos - fragPos);
		float rangeCheck = smoothstep(0.0, 1.0, 1.0 - dist);
		occlusion += rangeCheck * max(0.0, dot(normal, normalize(sampleWorldPos - fragPos)));
	}
	return 1.0 - (occlusion / sampleCount);
}




vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoords) {
	//float depth = Texel(depthTexture, texCoord).r;
	float depth = Texel(tex, texCoord).r;
	vec3 fragPos = reconstructPosition(depth, texCoord);

	// approximate normal using neighboring depth values (simple normal reconstruction)
	vec3 normal = vec3(0.0, 0.0, 1.0); // TODO: implement normal reconstruction

	float ao = calculateAmbientOcclusion(fragPos, normal, tex);
	return vec4(vec3(ao), 1.0);
}


