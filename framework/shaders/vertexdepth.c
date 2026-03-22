
#pragma language glsl3

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;

// mesh variables
uniform mat4 meshMatrix;
attribute vec4 instMatColumn1;
attribute vec4 instMatColumn2;
attribute vec4 instMatColumn3;
attribute vec4 instMatColumn4;


uniform bool isInstanced;



// vertical field-of-view is used
mat4 getPerspectiveMatrix(float fieldOfView, float aspect) {
	float tanHalfFov = tan(fieldOfView / 2.0);

	mat4 perspectiveMatrix = mat4(0.0);
	perspectiveMatrix[0][0] = 1.0 / (aspect * tanHalfFov);
	perspectiveMatrix[1][1] = 1.0 / (tanHalfFov);
	perspectiveMatrix[2][2] = -(zFar + zNear) / (zFar - zNear);
	perspectiveMatrix[2][3] = -1.0;
	perspectiveMatrix[3][2] = -(2.0 * zFar * zNear) / (zFar - zNear);

	return perspectiveMatrix;
}



vec4 position(mat4 transform_projection, vec4 vertex_position) {
	mat4 modelWorldMatrix;

	// get the scale matrix, then the rotation matrix in XYZ order, then the translation matrix
	if (isInstanced) {
		modelWorldMatrix = mat4(instMatColumn1, instMatColumn2, instMatColumn3, instMatColumn4);
	} else {
		modelWorldMatrix = meshMatrix;
	}

	mat4 cameraWorldMatrix = camMatrix;
	mat4 viewMatrix = inverse(cameraWorldMatrix);

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;

	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	// apply the view-projection transformation
	vec4 result = projectionMatrix * cameraSpaceMatrix * vertex_position;

	return result;
}
