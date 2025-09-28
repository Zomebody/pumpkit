
#pragma language glsl3

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;
uniform mat4 sunWorldMatrix;
uniform mat4 orthoMatrix;

uniform float currentTime;

// attributes
attribute vec3 VertexNormal;
attribute vec3 VertexTangent;
attribute vec3 VertexBitangent;
attribute vec3 SurfaceNormal;

// wind variables
uniform vec3 windVelocity; // direction and speed of the wind. Animations happen faster at higher velocities
uniform float windStrength; // the maximum angle in radians that vertices get rotated due to the wind


const float zNear = 0.1;
const float zFar = 1000.0;

// mesh variables
attribute vec3 instancePosition; // TODO: replace with a meshMatrix
attribute vec3 instanceRotation; // TODO: replace with a meshMatrix
attribute vec3 instanceScale; // TODO: replace with a meshMatrix
attribute vec3 instanceColor;
attribute vec3 instanceColorShadow;
varying vec3 instColor;
varying vec3 instColorShadow;
//uniform bool isInstanced;

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
//varying vec3 fragViewNormal; // used for normal map for SSAO (in screen space)
varying vec3 fragWorldNormal; // normal vector, but in world space this time
varying vec3 fragWorldSurfaceNormal; // specifically required to solve shadow acne
varying vec4 fragPosLightSpace; // position of the fragment in light space so it can sample from the shadow map
//varying mat3 TBN; // tangent bitangent normal matrix to be used for normal maps



// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS (probably because of row/column major order?)

// rotate around X-axis
mat4 getRotationMatrixX(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		1.0, 0.0, 0.0, 0.0,
		0.0, c,   s,   0.0,
		0.0, -s,  c,   0.0,
		0.0, 0.0, 0.0, 1.0
	);
}



// rotate around Y-axis
mat4 getRotationMatrixY(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   0.0, -s,  0.0,
		0.0, 1.0, 0.0, 0.0,
		s,   0.0, c,   0.0,
		0.0, 0.0, 0.0, 1.0
	);
}


// rotate around Z-axis
mat4 getRotationMatrixZ(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat4(
		c,   s,   0.0, 0.0,
		-s,  c,   0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0
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





// worldPos is only needed to calculate where in the sine's phase the vertex is
// unlike foliage, plants don't rotate around their center but rather around z=0
vec3 windTransform(vec3 vertexOffset, mat4 rotationMatrix, vec3 worldPos) {
	// at center of mesh so cannot move anyway
	if (length(windVelocity) < 0.000001) {
		return vertexOffset;
	}

	vec3 localZ = normalize((rotationMatrix * vec4(0.0, 0.0, 1.0, 0.0)).xyz); // rotate local-space up-vector to world-space
	float factor = dot(localZ, vertexOffset);
	vec3 pivot = vertexOffset - localZ * factor;

	//vec3 pivot = vec3(vertexOffset.x, vertexOffset.y, 0.0);
	vec3 relVector = vertexOffset - pivot;

	// if == 0 this would cause undefined behavior, so exit early
	if (length(relVector) < 0.000001) {
		return vertexOffset;
	}

	vec3 relNorm  = normalize(relVector);
	vec3 windNorm = normalize(windVelocity);

	// calculate an axis that is perpendicular to the plane formed by relNorm and windNorm
	vec3 axis = cross(relNorm, windNorm);
	if (length(axis) < 0.000001) { // if the two points are the same, axis will be a 0-vector. Solve edge-case by returning early
		return vertexOffset;
	}
	axis = normalize(axis); // normalize axis because cross-product rarely ever outputs a unit vector

	// how much of the strength to apply by projecting the wind onto the vertex's offset. influence is in range [0,1] where it's 0 if parallel to wind direction, 1 if perpendicular
	float influence = 1.0 - abs(dot(relNorm, windNorm));

	// calculate angle depending on the time, wind speed and world location
	// imagine a plane perpendicular to windDir is moving through space, dot(windDir, worldPos) calculates at what time-step the plane intersects worldPos.
	float phaseOffset = -dot(windNorm, worldPos) / length(windVelocity);
	float angle = windStrength * influence * sin(phaseOffset + currentTime * length(windVelocity));

	// rotate vertex around point using Rodrigues formula
	vec3 rotatedVector =
		vertexOffset * cos(angle) +
		cross(axis, vertexOffset) * sin(angle) +
		axis * dot(axis, vertexOffset) * (1.0 - cos(angle));

	return rotatedVector;
}








vec4 position(mat4 transform_projection, vec4 vertex_position) {
	// model transformations
	mat4 scaleMatrix = getScaleMatrix(instanceScale);
	mat4 rotationMatrix = getRotationMatrixZ(instanceRotation.z) * getRotationMatrixY(instanceRotation.y) * getRotationMatrixX(instanceRotation.x);
	mat4 translationMatrix = getTranslationMatrix(instancePosition);
	instColor = instanceColor; // pass color attribute from vertex shader to the fragment shader since the fragment shader doesn't support attributes for some reason?
	instColorShadow = instanceColorShadow;


	// construct the model's world matrix, i.e. where in the world is each vertex of this mesh located
	mat4 relativePosMatrix = rotationMatrix * scaleMatrix; // where the vertex is located relative to the center of the mesh
	vec4 relativeVertexPos = relativePosMatrix * vertex_position;
	vec3 vertexAfterWind = windTransform(relativeVertexPos.xyz, rotationMatrix, (translationMatrix * relativeVertexPos).xyz);
	fragWorldPosition = (translationMatrix * vec4(vertexAfterWind, 1.0)).xyz;

	mat4 modelWorldMatrix = translationMatrix * relativePosMatrix;
	
	mat4 cameraWorldMatrix = camMatrix;
	mat4 viewMatrix = inverse(cameraWorldMatrix);

	vec4 viewPos = viewMatrix * vec4(fragWorldPosition, 1.0);

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	//mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;

	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	// apply the view-projection transformation
	vec4 result = projectionMatrix * viewPos;



	mat3 normalMatrixModel = transpose(inverse(mat3(modelWorldMatrix))); // needed to calculate normals properly for non-uniform scaling
	fragWorldNormal = normalize(normalMatrixModel * VertexNormal);
	
	// init variables for shadow map
	mat4 sunViewMatrix = inverse(sunWorldMatrix);
	fragPosLightSpace = orthoMatrix * sunViewMatrix * vec4(fragWorldPosition, 1.0);


	return result;
}