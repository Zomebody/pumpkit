
#pragma language glsl3


#ifdef VERTEX

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

const float zNear = 0.1;
const float zFar = 1000.0;

// mask variables
uniform vec3 worldPosition; // position in world coordinates
// from 0 to inner radius is fully see-through
uniform float innerRadius; // in world units
// from inner radius to outer radius linearly becomes thicker dithering effect until it's opaque
uniform float outerRadius;


attribute float VertexIsInner;

varying float depth;

/*
mesh format:

local mesh = love.graphics.newMesh(
	{
		{"VertexPosition", "float", 2},
		{"VertexIsInner", "byte", 1},
	},
	vertices,
	"triangles",
	"static"
)
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





// super simple billboard behavior with some mesh deformation prepended
vec4 position(mat4 transform_projection, vec4 vertex_position) {

	// scale vertex away from center depending on if it's in the inner circle or outer circle. Vertex positions will be laying at a distance of 1 around the center
	// the one exception is the center vertex, but that one is at 0,0 so no matter the multiplier it'll always remain at the center
	vec2 position = vertex_position.xy * vec2(VertexIsInner * innerRadius) + vertex_position.xy * vec2((1.0 - VertexIsInner) * outerRadius);



	mat4 viewMatrix = inverse(camMatrix);


	// apply billboard behavior (move to world position, then offset using the camera's model axes)
	vec3 camRight = normalize(camMatrix[0].xyz);
	vec3 camUp = normalize(camMatrix[1].xyz);
	vec3 worldPos = worldPosition + (camRight * position.x) + (camUp * position.y);

	// transform to clip space
	mat4 perspectiveMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);
	vec4 result = perspectiveMatrix * viewMatrix * vec4(worldPos, 1.0);

	float ndcDepth = result.z / result.w; // range -1, 1
	depth = ndcDepth * 0.5 + 0.5;
	//depth = result.z;

	return result;
}

#endif



// fragment Shader
#ifdef PIXEL

varying float depth;

vec2 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {

	// TODO: write depth as a color to the canvas
	// r = 0 if no mask, 1 if mask
	// g = depth

	//return Texel(tex, texture_coords) * color;
	return vec2(1.0, depth);
}

#endif

