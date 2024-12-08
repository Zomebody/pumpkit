


/*

	TODO:
	1. different facing directions options (A: facing world-up and B: facing the emitter's source position)
	2. option for particle emitter to be affected by light
	

*/




#ifdef VERTEX

const float zNear = 0.1;
const float zFar = 1000.0;

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

// update variables
uniform Image dataTexture; // data texture containing (currently) the color gradient and size curve
uniform vec3 gravity; // direction the particle accelerates into
uniform float currentTime; // current world time, used to calculate how old an instance is


// mesh variables
attribute vec3 instPosition;
attribute float instEmittedAt;
attribute float instLifetime; // particles only rotate along one axis (the axis they face, i.e. the camera)
attribute vec3 instVelocity;
attribute float instRotation;
attribute float instRotationSpeed;
attribute float instScaleOffset;
attribute float instFacingMode; // if 0: facing world up, if 0.25: regular billboard behavior, if 0.5: facing velocity, if 0.75: faces camera (billboard) while rotating towards velocity

varying float emittedAt;
varying float lifetime;

//varying vec3 instColor;
//varying bool tooOld; // whether the instance is too old to be drawn



// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS (probably because of row/column major order shenanigans?)

// Function to create a rotation matrix around the X axis
mat4 getRotationMatrixX(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		1.0, 0.0, 0.0, 0.0,
		0.0, c,   s,  0.0,
		0.0, -s,    c,  0.0,
		0.0, 0.0, 0.0, 1.0
	);
}



// Function to create a rotation matrix around the Y axis
mat4 getRotationMatrixY(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   0.0, -s,   0.0,
		0.0, 1.0, 0.0, 0.0,
		s,  0.0, c,   0.0,
		0.0, 0.0, 0.0, 1.0
	);
}



// Function to create a rotation matrix around the Z axis
mat4 getRotationMatrixZ(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   s,   0.0, 0.0,
		-s,    c,   0.0, 0.0,
		0.0,  0.0, 1.0, 0.0,
		0.0,  0.0, 0.0, 1.0
	);
}



mat4 getScaleMatrix(vec3 amount) {
	return mat4(
		amount.x, 0.0,      0.0,      0.0,
		0.0,      amount.y, 0.0,      0.0,
		0.0,      0.0,      amount.z, 0.0,
		0.0,      0.0,      0.0,      1.0
	);
}



mat4 getTranslationMatrix(vec3 translation) {
	return mat4(
		1.0, 0.0, 0.0, 0.0,
		0.0, 1.0, 0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		translation.x, translation.y, translation.z, 1.0
	);
}



// vertical field-of-view is used
mat4 getPerspectiveMatrix(float fieldOfView, float aspect) {
	float tanHalfFov = tan(fieldOfView / 2.0);

	mat4 perspectiveMatrix = mat4(0.0);
	perspectiveMatrix[0][0] = 1.0 / (aspect * tanHalfFov);
	perspectiveMatrix[1][1] = 1.0 / (tanHalfFov);
	perspectiveMatrix[2][2] = -(zFar + zNear) / (zFar - zNear);
	perspectiveMatrix[2][3] = -1.0;
	perspectiveMatrix[3][2] = -(2.0 * zFar * zNear) / (zFar - zNear);
	perspectiveMatrix[3][3] = 0.0;

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



// for a given camera matrix and particle instance position, calculate the rotation matrix to apply to the particle for it to display 'billboard behavior'
mat4 getBillboardMatrix(mat4 cMatrix, vec3 iPosition) {
	// get the camera's forward and up vectors
	vec3 cameraFront = -normalize(vec3(cMatrix[2][0], cMatrix[2][1], cMatrix[2][2])); // negative Z-axis
	vec3 cameraUp = normalize(vec3(cMatrix[1][0], cMatrix[1][1], cMatrix[1][2])); // Y-axis

	// get the right-vector
	vec3 right = normalize(cross(cameraUp, cameraFront));

	// get the up-vector
	vec3 up = cross(cameraFront, right);

	// create rotation matrix from the front, right and upvector
	mat4 billboardMatrix = mat4(1.0);
	billboardMatrix[0] = vec4(right, 0.0);
	billboardMatrix[1] = vec4(up, 0.0);
	billboardMatrix[2] = vec4(cameraFront, 0.0);

	return billboardMatrix;
}



mat4 getVelocityFacingMatrix(vec3 velocity) {
	// normalize vector
	vec3 forward = normalize(velocity);
	if (length(velocity) < 0.001) {
		forward = vec3(0.0, 0.0, 1.0);
	}

	// calculate the right vector as cross product of up and forward
	vec3 right = normalize(cross(vec3(0.0, 0.0, 1.0), forward));

	// reclculate the up vector to ensure orthogonality
	vec3 newUp = cross(forward, right);

	// rotation matrix
	mat4 velocityFacingMatrix = mat4(1.0);
	velocityFacingMatrix[0] = vec4(right, 0.0);
	velocityFacingMatrix[1] = vec4(newUp, 0.0);
	velocityFacingMatrix[2] = vec4(forward, 0.0);

	return velocityFacingMatrix;
}



mat4 getBillboardRotatedToHeadingMatrix(mat4 cMatrix, vec3 iPosition, vec3 velocity, mat4 projectionMatrix, mat4 viewMatrix) {
	// create a basic billboard matrix
	mat4 billboardMatrix = getBillboardMatrix(cMatrix, iPosition);

	// calculate the velocity direction in screen space
	vec4 screenVelocity = projectionMatrix * viewMatrix * vec4(iPosition + velocity, 1.0);
	vec4 screenPosition = projectionMatrix * viewMatrix * vec4(iPosition, 1.0);
	vec2 velocityScreenDir = normalize(screenVelocity.xy / screenVelocity.w - screenPosition.xy / screenPosition.w);

	// compute rotation angle
	float angle = atan(velocityScreenDir.y, velocityScreenDir.x);

	// create rotation matrix
	float cosTheta = cos(angle);
	float sinTheta = sin(angle);
	mat4 rotationMatrix = mat4(1.0);
	rotationMatrix[0][0] = cosTheta;
	rotationMatrix[0][1] = -sinTheta;
	rotationMatrix[1][0] = sinTheta;
	rotationMatrix[1][1] = cosTheta;

	// Combine billboard and rotation matrices
	return billboardMatrix * rotationMatrix;
}



// size curve decoding
// number curves are stored across two channels (r & g or b & a) to ensure enough bit precision. This does mean we need more work to extract that information
float decodeFromChannels(float high, float low) {
	return high + (low / 256.0); // Combine high and low channels
}



float computeSize(float ageFraction, float offset) {
	float curveU = clamp(ageFraction, 0.0, 1.0);
	vec2 sizeUV = vec2(curveU, 0.75); // Bottom row (assume 2-pixel tall texture, so Y = 0.75)
	vec4 sizeData = Texel(dataTexture, sizeUV);

	float baseScale = decodeFromChannels(sizeData.r, sizeData.g) * 10.0; // Decode base scale
	float deviation = decodeFromChannels(sizeData.b, sizeData.a) * 10.0; // Decode deviation
	return baseScale + (deviation * offset);
}







vec4 position(mat4 transform_projection, vec4 vertex_position) {
	// model transformations
	// get the scale matrix
	mat4 scaleMatrix;
	mat4 rotationMatrix;
	mat4 facingMatrix;
	mat4 translationMatrix;

	// some of the camera calculations are moved up here because they are necessary for one of the particle rotation modes!
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);
	mat4 cameraWorldMatrix = camMatrix;
	mat4 viewMatrix = inverse(cameraWorldMatrix);


	float size = computeSize((currentTime - instEmittedAt) / instLifetime, instScaleOffset);
	vec3 worldPosition = instPosition + instVelocity * (currentTime - instEmittedAt) + 0.5 * gravity * pow((currentTime - instEmittedAt), 2.0);

	
	scaleMatrix = getScaleMatrix(vec3(size, size, size));
	rotationMatrix = getRotationMatrixZ(instRotation + instRotationSpeed * (currentTime - instEmittedAt));
	if (instFacingMode == 0.0) { // world up
		facingMatrix = mat4(1.0); // no rotation, i.e. identity matrix
	} else if (instFacingMode == 0.25) { // billboard
		facingMatrix = getBillboardMatrix(camMatrix, worldPosition);
	} else if (instFacingMode == 0.5) { // facing velocity
		facingMatrix = getVelocityFacingMatrix(instVelocity + gravity * (currentTime - instEmittedAt));
	} else { // billboard, but rotated towards velocity
		facingMatrix = getBillboardRotatedToHeadingMatrix(camMatrix, worldPosition, instVelocity + gravity * (currentTime - instEmittedAt), projectionMatrix, viewMatrix);
	}
	
	translationMatrix = getTranslationMatrix(worldPosition);
	


	
	// construct the model's world matrix, i.e. where in the world is each vertex of this particle located
	mat4 modelWorldMatrix = translationMatrix * facingMatrix * rotationMatrix * scaleMatrix;

	

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;


	// Apply the view-projection transformation
	vec4 result = projectionMatrix * cameraSpaceMatrix * vertex_position;

	emittedAt = instEmittedAt;
	lifetime = instLifetime;


	return result;
}

#endif








// Fragment Shader
#ifdef PIXEL


// colors
//varying vec3 instColor;
//varying bool tooOld;

uniform Image dataTexture; // data texture containing (currently) the color gradient and size curve
uniform float currentTime;


varying float emittedAt;
varying float lifetime;



// fragment shader
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	float ageFraction = (currentTime - emittedAt) / lifetime;
	if (ageFraction > 1) {
		discard;
	}

	// sample the gradient color from the top row of the data texture
    float gradientU = clamp(ageFraction, 0.0, 1.0); // Ensure it stays within the range [0, 1]
    vec2 gradientUV = vec2(gradientU, 0.25); // Top row (assume 2-pixel tall texture, so Y = 0.25 for the top row)
    vec4 gradientColor = Texel(dataTexture, gradientUV);

	// Check if a texture is applied by sampling from it
	vec4 texColor = Texel(tex, texture_coords);

	// Check if the alpha of the texture color is below a threshold
	
	if (texColor.a < 0.01) {
		discard;  // Discard fully transparent pixels
	}
	
	
	return texColor * gradientColor;
}

#endif