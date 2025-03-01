
#ifdef VERTEX

// camera variables
uniform mat4 camMatrix;
uniform float aspectRatio;
uniform float fieldOfView;

// attributes
attribute vec3 VertexNormal;


const float zNear = 0.1;
const float zFar = 1000.0;

// IMPORTANT: in our world we apply rotation in the order Z, X, Y
// mesh variables
uniform vec3 meshPosition;
uniform vec3 meshRotation;
uniform vec3 meshScale;
attribute vec3 instancePosition;
attribute vec3 instanceRotation;
attribute vec3 instanceScale;
attribute vec3 instanceColor;
varying vec3 instColor;
uniform bool isInstanced;

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragNormal; // used for normal map for SSAO (in screen space)
varying vec3 fragWorldNormal; // normal vector, but in world space this time



// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS (probably because of row/column major order shenanigans?)

// Function to create a rotation matrix around the X axis
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



// Function to create a rotation matrix around the Y axis
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



// Function to create a rotation matrix around the Z axis
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



// should be correct. Verify here: https://github.com/glslify/glsl-inverse/blob/master/index.glsl
mat4 inverse(mat4 m) {
	float
		a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3],
		a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3],
		a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3],
		a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3],

	b00 = a00 * a11 - a01 * a10,
	b01 = a00 * a12 - a02 * a10,
	b02 = a00 * a13 - a03 * a10,
	b03 = a01 * a12 - a02 * a11,
	b04 = a01 * a13 - a03 * a11,
	b05 = a02 * a13 - a03 * a12,
	b06 = a20 * a31 - a21 * a30,
	b07 = a20 * a32 - a22 * a30,
	b08 = a20 * a33 - a23 * a30,
	b09 = a21 * a32 - a22 * a31,
	b10 = a21 * a33 - a23 * a31,
	b11 = a22 * a33 - a23 * a32,

	det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

	if (abs(det) < 0.00001) {
		return mat4(1.0); // If determinant is 0, return identity matrix (or handle however you want)
	}

	float invDet = 1.0 / det;

	return mat4(
		(a11 * b11 - a12 * b10 + a13 * b09) * invDet,
		(a02 * b10 - a01 * b11 - a03 * b09) * invDet,
		(a31 * b05 - a32 * b04 + a33 * b03) * invDet,
		(a22 * b04 - a21 * b05 - a23 * b03) * invDet,
		(a12 * b08 - a10 * b11 - a13 * b07) * invDet,
		(a00 * b11 - a02 * b08 + a03 * b07) * invDet,
		(a32 * b02 - a30 * b05 - a33 * b01) * invDet,
		(a20 * b05 - a22 * b02 + a23 * b01) * invDet,
		(a10 * b10 - a11 * b08 + a13 * b06) * invDet,
		(a01 * b08 - a00 * b10 - a03 * b06) * invDet,
		(a30 * b04 - a31 * b02 + a33 * b00) * invDet,
		(a21 * b02 - a20 * b04 - a23 * b00) * invDet,
		(a11 * b07 - a10 * b09 - a12 * b06) * invDet,
		(a00 * b09 - a01 * b07 + a02 * b06) * invDet,
		(a31 * b01 - a30 * b03 - a32 * b00) * invDet,
		(a20 * b03 - a21 * b01 + a22 * b00) * invDet
	);
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
	} else {
		// for regular meshes, use the mesh position/rotation/scale variables
		scaleMatrix = getScaleMatrix(meshScale);
		rotationMatrix = getRotationMatrixZ(meshRotation.z) * getRotationMatrixY(meshRotation.y) * getRotationMatrixX(meshRotation.x);
		translationMatrix = getTranslationMatrix(meshPosition);
	}
	
	// construct the model's world matrix, i.e. where in the world is each vertex of this mesh located
	mat4 modelWorldMatrix = translationMatrix * rotationMatrix * scaleMatrix;

	//vec4 vertexWorldPosition = translationMatrix * rotationMatrix * scaleMatrix * vertex_position;

	// camera transformations
	// camera translation
	//				mat4 camTranslationMatrix = getTranslationMatrix(cameraPosition);
	// camera rotation
	//				mat4 camRotationMatrix = getRotationMatrixZ(cameraRotation) * getRotationMatrixX(cameraTilt);
	// camera offset
	//				mat4 camOffsetMatrix = getTranslationMatrix(vec3(0, 0, cameraOffset));
	// combine it all to get the camera matrix
	//				mat4 cameraWorldMatrix = camTranslationMatrix * camRotationMatrix * camOffsetMatrix; // offset first to create a pivot point to rotate around, then rotate, then translate to the right position
	mat4 cameraWorldMatrix = camMatrix;


	mat4 viewMatrix = inverse(cameraWorldMatrix);

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;

	fragWorldPosition = (modelWorldMatrix * vertex_position).xyz; // sets the world position of this vertex. In the fragment shader this gets interpolated correctly automatically
	
	// TODO: calculate distance to camera for any fog applied in the fragment shader
	//fragDistanceToCamera = length(fragWorldPosition - cameraMatrix[3].xyz); // convert camera matrix to vec3 containing only the position


	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	// Apply the view-projection transformation
	vec4 result = projectionMatrix * cameraSpaceMatrix * vertex_position;


	fragNormal = (viewMatrix * rotationMatrix * vec4(VertexNormal, 0.0)).xyz; // fragNormal is stored in view-space because it's cheaper and easier that way to program ambient-occlusion!

	//mat3 normalMatrix = mat3(transpose(inverse(modelWorldMatrix)));
	//fragWorldNormal = normalize(normalMatrix * VertexNormal);
	fragWorldNormal = (rotationMatrix * scaleMatrix * vec4(VertexNormal, 0.0)).xyz;



	// set variables for backface culling
	//cameraViewDirection = normalize(vec3(viewMatrix[3]) - fragWorldPosition);

	return result;
}

#endif









// Fragment Shader
#ifdef PIXEL

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
varying vec3 fragNormal; // used for normal map
varying vec3 fragWorldNormal;
//varying float fragDistanceToCamera; // used for fog
//varying vec3 cameraViewDirection;

uniform float currentTime;
uniform float diffuseStrength;

// uvs
uniform vec2 uvVelocity; // how quckly the UV scrolls on the X and Y axis, usually this equals 0,0

// lights
uniform vec3 lightPositions[16]; // non-transformed!
uniform vec3 lightColors[16];
uniform float lightRanges[16];
uniform float lightStrengths[16];
uniform vec3 ambientColor;

// colors
uniform vec3 meshColor;
uniform float meshBrightness; // if 1, mesh is not affected by diffuse shading at all
uniform float meshTransparency; // how transparent the mesh is
uniform float meshBloom;
varying vec3 instColor;


uniform bool isInstanced;

// triplanar texture projection variables
uniform float triplanarScale;

// textures
uniform Image MainTex; // used to be the 'tex' argument, but is now passed separately in this specific variable name because we switched to multi-canvas shading which has no arguments
uniform Image normalMap;







// fragment shader

void effect() {

	vec4 color = VaryingColor; // argument 'color' doesn't exist when using multiple canvases, so use built-in VaryingColor
	//Image tex = MainTex;
	if (isInstanced) {
		color = vec4(color.x * instColor.x, color.y * instColor.y, color.z * instColor.z, color.w);
	} else {
		color = vec4(color.x * meshColor.x, color.y * meshColor.y, color.z * meshColor.z, color.w);
	}
	
	/*
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	*/

	

	// sample the pixel to display from the supplied texture. For triplanar projection: use world coordinates and surface normal to sample. For regular meshes, use uv coordinates and uvvelocity
	vec4 texColor;
	vec2 texture_coords;
	if (triplanarScale > 0.0) { // project texture onto mesh using triplanar projection
		// calculate surface normal using interpolated vertex normal and derivative wizardry
		vec3 dFdx = dFdx(fragWorldPosition);
		vec3 dFdy = dFdy(fragWorldPosition);
		vec3 surfaceNormal = normalize(cross(dFdx, dFdy));
		if (dot(surfaceNormal, fragWorldNormal) < 0.0) {
			surfaceNormal = -surfaceNormal;
		}
		surfaceNormal = normalize(surfaceNormal);

		float absNormX = abs(surfaceNormal.x); // fragWorldNormal
		float absNormY = abs(surfaceNormal.y); // fragWorldNormal
		float absNormZ = abs(surfaceNormal.z); // fragWorldNormal
		if (absNormX > absNormY && absNormX > absNormZ) {
			// pointing into x-direction
			texture_coords = vec2(fragWorldPosition.y * triplanarScale, fragWorldPosition.z * triplanarScale);
			texColor = vec4(1.0, 0.0, 0.0, 1.0);
		} else if (absNormY > absNormZ) {
			// pointing into y-direction
			texture_coords = vec2(fragWorldPosition.x * triplanarScale, fragWorldPosition.z * triplanarScale);
			texColor = vec4(0.0, 1.0, 0.0, 1.0);
		} else {
			// pointing into z-direction
			texture_coords = vec2(fragWorldPosition.x * triplanarScale, fragWorldPosition.y * triplanarScale);
			texColor = vec4(0.0, 0.0, 1.0, 1.0);
		}
	} else { // simply grab the uv coordinates for applying the texture
		texture_coords = VaryingTexCoord.xy; // argument 'texture_coords' doesn't exist when doing multi-canvas operations, so extract it from VaryingTexCoord instead
	}
	texColor = Texel(MainTex, texture_coords - uvVelocity * currentTime) * vec4(1.0, 1.0, 1.0, 1.0 - meshTransparency);
	//texColor = texColor + vec4(meshTransparency, uvVelocity.x, currentTime, 0.0) * 0.000000001; // debug surface normal visualization

	// check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01) {
		discard;  // discard fully transparent pixels
	}


	// the second canvas is the normals canvas. Output the surface normal to this canvas
	love_Canvases[1] = vec4(fragNormal.x / 2 + 0.5, fragNormal.y / 2 + 0.5, fragNormal.z / 2 + 0.5, 1.0); // Pack normals into an RGBA format


	// ended up implementing a very basic naive additive lighting system because it doesn't have any weird edge-cases
	vec3 lighting = ambientColor; // start with just ambient lighting on the surface
	
	// add the lighting contribution of all lights to the surface
	for (int i = 0; i < 16; ++i) {
		if (lightStrengths[i] > 0.0) { // Only consider lights with a strength above 0
			vec3 lightDir = normalize(lightPositions[i] - fragWorldPosition);
			float distance = length(lightPositions[i] - fragWorldPosition);
			float attenuation = clamp(1.0 - pow(distance / lightRanges[i], 1.0), 0.0, 1.0);

			// diffuse shading
			float diffuseFactor = max(dot(fragWorldNormal, lightDir), 0.0);
			vec3 light = lightColors[i] * lightStrengths[i] * attenuation;
			//float diffStrength = diffuseStrength * (1.0 - meshBrightness); // if a mesh is fully bright, diffuse strength becomes 0 so that it has no efect
			lighting += light * ((diffuseFactor * diffuseStrength) + (1.0 - diffuseStrength)); // if diffStrength==0, just add the color, otherwise, add based on angle between surface and light direction
		}
	}

	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	love_Canvases[0] = texColor * color * (vec4(lighting.x, lighting.y, lighting.z, 1.0) * (1.0 - meshBrightness) + vec4(1.0, 1.0, 1.0, 1.0) * meshBrightness);

	// apply bloom to canvas. Semi-transparent meshes will emit weaker bloom
	love_Canvases[2] = vec4(color.x * meshBloom, color.y * meshBloom, color.z * meshBloom, 1.0 - meshTransparency);
	

}

#endif