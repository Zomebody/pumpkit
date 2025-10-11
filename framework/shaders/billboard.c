
#pragma language glsl3


#ifdef VERTEX

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;

// billboard variables
uniform float rotation; // rotation (in radians)
uniform vec3 worldPosition; // position in world coordinates
uniform vec2 center; // where on the rectangle the center lays
uniform vec2 worldSize; // size in world coordinates
uniform vec2 pixelSize; // size in screen pixels


// make sure the mesh looks like this:
/*

  0,0,0
	┌───────────┐
	│         ╱ │
	│       ╱   │
	│     ╱     │
	│   ╱       │
	│ ╱         │
	└───────────┘
		 	  1,1,0

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


mat2 getRotationMatrix2d(float rot) {
	float c = cos(rot);
	float s = sin(rot);
	return mat2(
		c, -s,
		s, c
	);
}



// don't quite understand how this works but the other approach I tried was applying pixel size all the way at the end
// and doing it all the way at the end was too hard to make work
vec2 pixelsSizeToWorldSize(mat4 viewMatrix) {
	// world to view-space
	vec4 viewPos = viewMatrix * vec4(worldPosition, 1.0);
	float depth = abs(viewPos.z);

	float tanHalfFov = tan(fieldOfView / 2.0);
	float worldPerPixel = (2.0 * depth * tanHalfFov) / love_ScreenSize.y;
	return pixelSize * worldPerPixel;
}



// NOT TESTED YET

vec4 position(mat4 transform_projection, vec4 vertex_position) {
	mat4 viewMatrix = inverse(camMatrix);

	// offsets from center. To be used all the way in the end to apply pixel size!
	vec2 fracOffset = vertex_position.xy - center;

	// use 'center' to offset the vertex positions along their x and y
	vertex_position = vertex_position - vec4(center.x, center.y, 0.0, 0.0);
	
	// use worldSize to scale the mesh's x and y
	vec2 newWorldSize = worldSize;
	if (pixelSize.x != 0.0 || pixelSize.y != 0.0) {
		newWorldSize = newWorldSize + pixelsSizeToWorldSize(viewMatrix);
	}
	vertex_position = vertex_position * vec4(newWorldSize.x, newWorldSize.y, 1.0, 1.0);

	// rotate the mesh along the center using unit circle
	mat2 rotMatrix = getRotationMatrix2d(rotation);
	vec2 rotatedXY = rotMatrix * vertex_position.xy;
	vertex_position = vec4(rotatedXY.x, rotatedXY.y, vertex_position.z, vertex_position.w);

	// apply billboard behavior (move to world position, then offset using the camera's model axes)
	vec3 camRight = normalize(camMatrix[0].xyz);
	vec3 camUp = normalize(camMatrix[1].xyz);
	vec3 worldPos = worldPosition + (camRight * vertex_position.x) + (camUp * vertex_position.y);

	// transform to clip space
	mat4 perspectiveMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);
	vec4 result = perspectiveMatrix * viewMatrix * vec4(worldPos, 1.0);

	// find out the x-axis and y-axis of the screen space after rotation.
	//vec2 rotUp = rotMatrix * vec2(0.0, 1.0);
	//vec2 rotRight = rotMatrix * vec2(1.0, 0.0);

	// apply pixel size. First offset on the rotation compensated x-axis then on the rotation compensated y-axis
	//vec2 newXY = result.xy + rotRight * fracOffset.x * (2.0 / love_ScreenSize.x * pixelSize.x) + rotUp * fracOffset.y * (2.0 / love_ScreenSize.y * pixelSize.y);

	// plug new x and y back into the result
	//result = vec4(newXY.x, newXY.y, result.z, result.w);

	return result;
}

#endif







// fragment Shader
#ifdef PIXEL

// default fragment shader
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	return Texel(tex, texture_coords) * color;
}

#endif

