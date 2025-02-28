
uniform mat4 lightSpaceMatrix;
//uniform mat4 modelMatrix;

uniform vec3 meshPosition; // TODO: replace with a meshMatrix
uniform vec3 meshRotation; // TODO: replace with a meshMatrix
uniform vec3 meshScale; // TODO: replace with a meshMatrix
attribute vec3 instancePosition; // TODO: replace with a meshMatrix
attribute vec3 instanceRotation; // TODO: replace with a meshMatrix
attribute vec3 instanceScale; // TODO: replace with a meshMatrix


// rotate around X-axis
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



// rotate around Y-axis
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


// rotate around Z-axis
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



vec4 position(mat4 transform_projection, vec4 vertex_position) {
	mat4 scaleMatrix;
	mat4 rotationMatrix;
	mat4 translationMatrix;

	// get the scale matrix, then the rotation matrix in XYZ order, then the translation matrix
	if (isInstanced) {
		// for instanced meshes, use the instance position/rotation/scale uniforms
		scaleMatrix = getScaleMatrix(instanceScale);
		rotationMatrix = getRotationMatrixZ(instanceRotation.z) * getRotationMatrixY(instanceRotation.y) * getRotationMatrixX(instanceRotation.x);
		translationMatrix = getTranslationMatrix(instancePosition);
		instColor = instanceColor; // pass color attribute from vertex shader to the fragment shader since the fragment shader doesn't support attributes for some reason?
	} else {
		// for regular meshes, use the mesh position/rotation/scale variables
		scaleMatrix = getScaleMatrix(meshScale);
		rotationMatrix = getRotationMatrixZ(meshRotation.z) * getRotationMatrixY(meshRotation.y) * getRotationMatrixX(meshRotation.x);
		translationMatrix = getTranslationMatrix(meshPosition);
	}

	mat4 modelMatrix = translationMatrix * rotationMatrix * scaleMatrix;
	return lightSpaceMatrix * modelMatrix * vec4(vertex_position.xyz, 1.0);
}