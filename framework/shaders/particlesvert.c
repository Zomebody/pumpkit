
#pragma language glsl3

const float zNear = 0.1;
const float zFar = 1000.0;

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;
uniform mat4 sunWorldMatrix;
uniform mat4 orthoMatrix;

// attributes
attribute vec3 VertexNormal;

// update variables
uniform Image dataTexture; // data texture containing (currently) the color gradient and size curve
uniform vec3 gravity; // direction the particle accelerates into
uniform float drag;
uniform float currentTime; // current world time, used to calculate how old an instance is
uniform float zOffset;


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

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragWorldNormal; // normal vector, but in world space this time
varying vec4 fragPosLightSpace;
varying float fragWorldDepth;



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
	return high + (low / 256.0); // combine high and low channels
}



float computeSize(float ageFraction, float offset) {
	float curveU = clamp(ageFraction, 0.0, 1.0);
	vec2 sizeUV = vec2(curveU, 0.75); // bottom row (assume 2-pixel tall texture, so Y = 0.75)
	vec4 sizeData = Texel(dataTexture, sizeUV);

	float baseScale = decodeFromChannels(sizeData.r, sizeData.g) * 10.0; // decode base scale
	float deviation = decodeFromChannels(sizeData.b, sizeData.a) * 10.0; // decode deviation
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


	vec3 worldVelocity, worldPosition;

	if (drag != 0.0) {
		// formula for drag is: 1/2^x, i.e. every second, velocity is halved
		vec3 draggedVelocity = instVelocity * (1.0 / pow(2.0, drag * (currentTime - instEmittedAt))); // velocity built up due to initial velocity, minus any drag that is applied
		vec3 gravityVelocity = gravity * (currentTime - instEmittedAt); // velocity built up due to gravity

		// how far you moved as a result of velocity and drag. This calculates the surface area under the curve 1/2^nx from 0 to how long the particle has lived for (x). n = drag.
		float dragCurveSurfaceArea = 1.0 / (drag * log(2.0)) * (1.0 - pow(2.0, -drag*(currentTime - instEmittedAt)));
		vec3 worldMovedThroughVelocity = instVelocity * dragCurveSurfaceArea;
		// how the particle has moved as a result of gravity dragging the particle into a certain direction
		vec3 worldMovedThroughGravity = 0.5 * gravity * pow((currentTime - instEmittedAt), 2.0);

		worldVelocity = draggedVelocity + gravityVelocity;
		worldPosition = instPosition + worldMovedThroughVelocity + worldMovedThroughGravity;
	} else {
		worldVelocity = instVelocity + gravity * (currentTime - instEmittedAt);
		worldPosition = instPosition + instVelocity * (currentTime - instEmittedAt) + 0.5 * gravity * pow((currentTime - instEmittedAt), 2.0);
	}

	worldPosition = worldPosition + normalize(cameraWorldMatrix[3].xyz - worldPosition) * zOffset;

	
	scaleMatrix = getScaleMatrix(vec3(size, size, size));
	rotationMatrix = getRotationMatrixZ(instRotation + instRotationSpeed * (currentTime - instEmittedAt));
	if (instFacingMode == 0.0) { // world up
		facingMatrix = mat4(1.0); // no rotation, i.e. identity matrix
	} else if (instFacingMode == 0.25) { // billboard
		facingMatrix = getBillboardMatrix(camMatrix, worldPosition);
	} else if (instFacingMode == 0.5) { // facing velocity
		facingMatrix = getVelocityFacingMatrix(worldVelocity);
	} else { // billboard, but rotated towards velocity
		facingMatrix = getBillboardRotatedToHeadingMatrix(camMatrix, worldPosition, worldVelocity, projectionMatrix, viewMatrix);
	}
	
	translationMatrix = getTranslationMatrix(worldPosition);
	


	
	// construct the model's world matrix, i.e. where in the world is each vertex of this particle located
	mat4 modelWorldMatrix = translationMatrix * facingMatrix * rotationMatrix * scaleMatrix;

	

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;


	// apply the view-projection transformation
	vec4 cameraRelative = cameraSpaceMatrix * vertex_position;
	fragWorldDepth = abs(cameraRelative.z);
	vec4 result = projectionMatrix * cameraRelative;

	emittedAt = instEmittedAt;
	lifetime = instLifetime;

	fragWorldPosition = (modelWorldMatrix * vertex_position).xyz; // worldPosition;
	fragWorldNormal = normalize((rotationMatrix * scaleMatrix * vec4(VertexNormal, 0.0)).xyz);

	mat4 sunViewMatrix = inverse(sunWorldMatrix);
	fragPosLightSpace = orthoMatrix * sunViewMatrix * vec4(fragWorldPosition, 1.0);


	return result;
}









