
#pragma language glsl3

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;
uniform mat4 sunWorldMatrix;
uniform mat4 orthoMatrix;

// attributes
attribute vec3 VertexNormal;
attribute vec3 VertexTangent;
attribute vec3 VertexBitangent;
attribute vec3 SurfaceNormal;


const float zNear = 0.1;
const float zFar = 1000.0;

// mesh variables
uniform vec3 meshPosition; // TODO: replace with a meshMatrix
uniform vec3 meshRotation; // TODO: replace with a meshMatrix
uniform vec3 meshScale; // TODO: replace with a meshMatrix
attribute vec3 instancePosition; // TODO: replace with a meshMatrix
attribute vec3 instanceRotation; // TODO: replace with a meshMatrix
attribute vec3 instanceScale; // TODO: replace with a meshMatrix
attribute vec3 instanceColor;
attribute vec3 instanceColorShadow;
varying vec3 instColor;
varying vec3 instColorShadow;
uniform bool isInstanced;

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragViewNormal; // used for normal map for SSAO (in screen space)
varying vec3 fragWorldNormal; // normal vector, but in world space this time
varying vec3 fragWorldSurfaceNormal; // specifically required to solve shadow acne
varying vec4 fragPosLightSpace; // position of the fragment in light space so it can sample from the shadow map
varying mat3 TBN; // tangent bitangent normal matrix to be used for normal maps



// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS (probably because of row/column major order?)

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

	return perspectiveMatrix;
}



vec4 position(mat4 transform_projection, vec4 vertex_position) {
	// model transformations
	// get the scale matrix
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
		instColorShadow = instanceColorShadow;
	} else {
		// for regular meshes, use the mesh position/rotation/scale variables
		scaleMatrix = getScaleMatrix(meshScale);
		rotationMatrix = getRotationMatrixZ(meshRotation.z) * getRotationMatrixY(meshRotation.y) * getRotationMatrixX(meshRotation.x);
		translationMatrix = getTranslationMatrix(meshPosition);
	}


	// construct the model's world matrix, i.e. where in the world is each vertex of this mesh located
	mat4 modelWorldMatrix = translationMatrix * rotationMatrix * scaleMatrix;

	mat4 cameraWorldMatrix = camMatrix;
	mat4 viewMatrix = inverse(cameraWorldMatrix);

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;

	fragWorldPosition = (modelWorldMatrix * vertex_position).xyz; // sets the world position of this vertex. In the fragment shader this gets interpolated correctly automatically

	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	// apply the view-projection transformation
	vec4 result = projectionMatrix * cameraSpaceMatrix * vertex_position;

	// TODO: DOUBLE CHECK IF THIS NORMAL FIX IS CORRECT
	mat3 normalMatrixModel = transpose(inverse(mat3(modelWorldMatrix))); // needed to calculate normals properly for non-uniform scaling
	fragWorldNormal = normalize(normalMatrixModel * VertexNormal);
	fragWorldSurfaceNormal = normalize(normalMatrixModel * SurfaceNormal);
	fragViewNormal = normalize(mat3(viewMatrix) * fragWorldNormal);

	vec3 fragWorldTangent = normalize((rotationMatrix * vec4(VertexTangent, 0.0)).xyz);
	vec3 fragWorldBitangent = normalize((rotationMatrix * vec4(VertexBitangent, 0.0)).xyz);

	// TBN needs to be in world-space
	TBN = mat3(
		fragWorldTangent,
		fragWorldBitangent,
		fragWorldNormal
	);

	

	mat4 sunViewMatrix = inverse(sunWorldMatrix);
	fragPosLightSpace = orthoMatrix * sunViewMatrix * vec4(fragWorldPosition, 1.0);


	return result;
}