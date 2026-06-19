#pragma language glsl3
#ifdef VERTEX

// implementation from here: https://learnopengl.com/Advanced-OpenGL/Cubemaps

varying vec3 texCoordsDirection;

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;



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

	texCoordsDirection = vec3(vertex_position.x, vertex_position.z, vertex_position.y);

	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);
	
	// remove translation from matrix by clamping to just the rotation 3x3 matrix
	mat4 viewMatrix = mat4(mat3(inverse(camMatrix)));

	vec4 result = projectionMatrix * viewMatrix * vec4(vertex_position.xyz, 1.0);
	return result;
}


#endif


// fragment Shader
#ifdef PIXEL

uniform CubeImage skyboxImage;
varying vec3 texCoordsDirection;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	return Texel(skyboxImage, normalize(texCoordsDirection));
}


#endif
