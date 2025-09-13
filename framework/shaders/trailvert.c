
#pragma language glsl3

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;


const float zNear = 0.1;
const float zFar = 1000.0;
const vec3 UP_DIRECTION = vec3(0.0, 0.0, 1.0);
const vec3 FRONT_DIRECTION = vec3(0.0, 1.0, 0.0);


const int MAX_POINTS = 15;
uniform vec3 bezierPoints[MAX_POINTS]; // buffer that stores points in the bezier curve in order (not all indices may be in use!)
uniform int pointCount; // how many points the supplied bezier contains, thus how many to sample from the above variable
uniform float age; // how many seconds ago the trail got emitted
uniform bool facesCamera;
uniform Image dataTexture;
uniform float duration;
uniform float length;
varying vec2 texCoords;




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



vec3 deCasteljeau(in vec3 points[MAX_POINTS], int n, float x) {
	vec3 tempPoints[MAX_POINTS];
	for (int i = 0; i < n; i++) {
		tempPoints[i] = points[i];
	}
	// interpolate. First go over all segments, then segments minus one, minus two etc.
	for (int a = 1; a < n; a++) {
		for (int b = 0; b < n - a; b++) {
			tempPoints[b] = mix(tempPoints[b], tempPoints[b + 1], x);
		}
	}
	return tempPoints[0];
}



vec3 getDirectionAt(float x) {
	int n = pointCount - 1;
	vec3 derivatives[MAX_POINTS];
	for (int i = 0; i < n; i++) {
		derivatives[i] = (bezierPoints[i + 1] - bezierPoints[i]) * float(n);
	}

	return normalize(deCasteljeau(derivatives, n, x));
}



vec3 getPositionAt(float x) {
	return deCasteljeau(bezierPoints, pointCount, x);
}



// calculates offset to the left
vec3 calculateOffset(vec3 direction, float width) {
	vec3 right;

	if (!facesCamera) {
		if (direction.z < 0.999999) {
			right = cross(direction, UP_DIRECTION);
		} else {
			right = cross(FRONT_DIRECTION, direction);
		}
	} else {
		vec3 camDirection = normalize((camMatrix * vec4(0.0, 0.0, -1.0, 0.0)).xyz); // it really do be this simple
		if (abs(dot(direction, camDirection)) < 0.999999) {
			right = cross(-direction, camDirection);
		} else {
			right = cross(FRONT_DIRECTION, direction);
		}
	}

	return right * 0.5 * width; // calculate offset points by doing point + offset and point - offset
}



// width curve decoding
// number curves are stored across two channels (r & g or b & a) to ensure enough bit precision. This does mean we need more work to extract that information
float decodeFromChannels(float high, float low) {
	return high + (low / 256.0); // combine high and low channels
}




vec4 position(mat4 transform_projection, vec4 vertex_position) {

	mat4 cameraWorldMatrix = camMatrix;
	mat4 viewMatrix = inverse(cameraWorldMatrix);

	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	texCoords = vertex_position.xy;

	// where on the curve the start and end of the mesh are positioned
	float x1 = age / duration;
	float x0 = (age - length) / duration;

	// where on the curve the current edge is positioned
	float x = mix(x0, x1, vertex_position.x);
	x = max(0.0, min(1.0, x));

	// decode width
	vec4 data = Texel(dataTexture, vec2(x, 0.5));
	float width = decodeFromChannels(data.r, data.g) * 64.0; // remap from 0-1 to 0-64


	vec3 direction = getDirectionAt(x);
	vec3 curvePosition = getPositionAt(x);

	vec3 offsetRight = calculateOffset(direction, width);
	vec3 left = curvePosition - offsetRight;
	vec3 right = curvePosition + offsetRight;

	vec4 world_vertex = vec4(mix(left, right, vertex_position.y), 1.0);

	// apply the view-projection transformation
	vec4 result = projectionMatrix * viewMatrix * world_vertex;


	return result;
}


