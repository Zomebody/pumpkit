#ifdef VERTEX

// camera variables
uniform vec3 cameraPosition;
uniform float cameraRotation;
uniform float cameraTilt;
uniform float cameraOffset;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 100.0;

// IMPORTANT: in our world we apply rotation in the order Z, X, Y
// mesh variables
uniform vec3 meshPosition;
uniform vec3 meshRotation;
uniform vec3 meshScale;

// TODO: light variables
uniform vec3 lightPositions[8]; // input world positions of lights
uniform vec3 lightColors[8]; // input colors of lights
uniform float lightRanges[8]; // input ranges of lights
uniform float lightStrengths[8]; // input strengths of lights
//uniform vec3 ambientColorClose;
//uniform float ambientClose;
//uniform vec3 ambientColorFar;
//uniform float ambientFar;
//varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
//varying float fragDistanceToCamera; // used for fog

// Function to create a rotation matrix around the X axis
mat4 getRotationMatrixX(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		1.0, 0.0, 0.0, 0.0,
		0.0, c,   -s,  0.0,
		0.0, s,    c,  0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

// Function to create a rotation matrix around the Y axis
mat4 getRotationMatrixY(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   0.0, s,   0.0,
		0.0, 1.0, 0.0, 0.0,
		-s,  0.0, c,   0.0,
		0.0, 0.0, 0.0, 1.0
	);
}

// Function to create a rotation matrix around the Z axis
mat4 getRotationMatrixZ(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   -s,   0.0, 0.0,
		s,    c,   0.0, 0.0,
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
	float tanHalfFov = tan(radians(fieldOfView) / 2.0);

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
	mat4 scaleMatrix = getScaleMatrix(meshScale);
	// get the rotation matrix in YXZ order
	mat4 rotationMatrix = getRotationMatrixX(meshRotation.y) * getRotationMatrixX(meshRotation.x) * getRotationMatrixZ(meshRotation.z);
	// get the translation matrix
	mat4 translationMatrix = getTranslationMatrix(meshPosition);
	// combine transformations. Transformations are applied from right to left. First scale, then rotate, then translate
	mat4 vertexWorldMatrix = translationMatrix * rotationMatrix * scaleMatrix * vertex_position;

	// camera transformations
	// camera translation
	mat4 camTranslationMatrix = getTranslationMatrix(cameraPosition);
	// camera rotation
	mat4 camRotationMatrix = getRotationMatrixX(meshRotation.x) * getRotationMatrixZ(meshRotation.z);
	// camera offset
	mat4 camOffsetMatrix = getTranslationMatrix(vec3(0, 0, camOffsetMatrix));
	// combine it all to get the camera matrix
	mat4 cameraMatrix = camTranslationMatrix * camRotationMatrix * camOffsetMatrix; // offset first to create a pivot point to rotate around, then rotate, then translate to the right position

	// TODO: set the world position variable to pass onto the fragment shader
	//fragWorldPosition = (vertexWorldMatrix * vertex_position).xyz; // sets the world position of this vertex. In the fragment shader this gets interpolated correctly automatically
	// TODO: calculate distance to camera for any fog applied in the fragment shader
	//fragDistanceToCamera = length(fragWorldPosition - cameraMatrix[3].xyz); // convert camera matrix to vec3 containing only the position

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = vertexWorldMatrix * inverse(cameraMatrix);

	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(aspectRatio);

	// Apply the view-projection transformation
	return viewProjectionMatrix * modelMatrix * vertex_position;
}

#endif



// Fragment Shader
#ifdef PIXEL

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	// Check if a texture is applied by sampling from it
	vec4 texColor = Texel(tex, texture_coords);

	// Check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.1) {
		discard;  // Discard fully transparent pixels
	}

	// lighting is done this way:
	// first calculate surface lighting on the fragment through adding the different point light colors at that fragment together
	// then calculate the ambient color at that fragment
	// finally multiply the two to get the resulting lighting at that fragment
	// then multiply the lighting with the surface color calculated below (vertex color and mesh image thing)


	// If the texture is effectively white (no texture) or the mesh has no texture applied
	// I don't think this is necessary?
	//if (texColor == vec4(1.0, 1.0, 1.0, 1.0)) {
	//	return color;  // Return the input color without modifying it
	//}

	// calculate surface lighting based on ambient and surrounding lights in range

	// Return the texture color multiplied by the input color
	return texColor * color;
}

#endif