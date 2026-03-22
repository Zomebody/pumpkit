
#pragma language glsl3

#ifdef VERTEX

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;

// mesh variables
//uniform vec3 meshPosition; // TODO: replace with a meshMatrix
//uniform vec3 meshRotation; // TODO: replace with a meshMatrix
//uniform vec3 meshScale; // TODO: replace with a meshMatrix
uniform mat4 meshMatrix;

//attribute vec3 instancePosition; // TODO: replace with a meshMatrix
//attribute vec3 instanceRotation; // TODO: replace with a meshMatrix
//attribute vec3 instanceScale; // TODO: replace with a meshMatrix
attribute vec4 instMatColumn1;
attribute vec4 instMatColumn2;
attribute vec4 instMatColumn3;
attribute vec4 instMatColumn4;

uniform bool isInstanced;


// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS (probably because of row/column major order?)
/*
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
*/


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


// bare minimum perspective transformation this time. No shading calculations are required because the silhouette is mono-color
vec4 position(mat4 transform_projection, vec4 vertex_position) {
	// model transformations
	// get the scale matrix
	//mat4 scaleMatrix;
	//mat4 rotationMatrix;
	//mat4 translationMatrix;
	mat4 modelWorldMatrix;

	// get the scale matrix, then the rotation matrix in XYZ order, then the translation matrix
	if (isInstanced) {
		// for instanced meshes, use the instance position/rotation/scale uniforms
		//scaleMatrix = getScaleMatrix(instanceScale);
		//rotationMatrix = getRotationMatrixZ(instanceRotation.z) * getRotationMatrixY(instanceRotation.y) * getRotationMatrixX(instanceRotation.x);
		//translationMatrix = getTranslationMatrix(instancePosition);
		modelWorldMatrix = mat4(instMatColumn1, instMatColumn2, instMatColumn3, instMatColumn4);
	} else {
		// for regular meshes, use the mesh position/rotation/scale variables
		//scaleMatrix = getScaleMatrix(meshScale);
		//rotationMatrix = getRotationMatrixZ(meshRotation.z) * getRotationMatrixY(meshRotation.y) * getRotationMatrixX(meshRotation.x);
		//translationMatrix = getTranslationMatrix(meshPosition);
		modelWorldMatrix = meshMatrix;
	}


	// construct the model's world matrix, i.e. where in the world is each vertex of this mesh located
	//mat4 modelWorldMatrix = translationMatrix * rotationMatrix * scaleMatrix;

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


#endif



// fragment Shader
#ifdef PIXEL

uniform vec4 silhouetteColor;

// sprites
uniform vec2 spritePosition;
uniform vec2 spriteSheetSize;
uniform bool isSpriteSheet;


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {

	vec2 coords;
	if (isSpriteSheet) {
		coords = texture_coords.xy / spriteSheetSize + spritePosition / spriteSheetSize;
	} else {
		coords = texture_coords.xy;
	}
	vec4 texColor = Texel(tex, coords);
	if (texColor.a < 0.01) {
		discard;
	}
	return vec4(silhouetteColor);
}


#endif