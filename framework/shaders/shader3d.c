
#ifdef VERTEX

// camera variables
// TODO: calculate camera's matrix and inverse matrix on the Lua side so it doesn't have to be recalculated every time in here
uniform vec3 cameraPosition;
uniform float cameraRotation;
uniform float cameraTilt;
uniform float cameraOffset;

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

// TODO: fragment variables
varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
//varying float fragDistanceToCamera; // used for fog
//varying vec3 fragNormal; // used for backface culling
//varying vec3 cameraViewDirection;



// I DON'T KNOW WHY, BUT THE FUNCTIONS GETROTATIONMATRIX AND GETSCALEMATRIX AND GETTRANSLATIONMATRIX ARE ALL TRANSPOSED AND IT JUST KIND OF WORKS

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
	perspectiveMatrix[3][3] = 0.0; // chatgpt suggested this for some reason????

	return perspectiveMatrix;
}



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
	mat4 scaleMatrix = getScaleMatrix(meshScale);
	// get the rotation matrix in YXZ order
	mat4 rotationMatrix = getRotationMatrixZ(meshRotation.z) * getRotationMatrixY(meshRotation.y) * getRotationMatrixX(meshRotation.x);
	// get the translation matrix
	mat4 translationMatrix = getTranslationMatrix(meshPosition);
	// combine transformations. Transformations are applied from right to left. First scale, then rotate, then translate
	mat4 modelWorldMatrix = translationMatrix * rotationMatrix * scaleMatrix;
	//vec4 vertexWorldPosition = translationMatrix * rotationMatrix * scaleMatrix * vertex_position;

	// camera transformations
	// camera translation
	mat4 camTranslationMatrix = getTranslationMatrix(cameraPosition);
	// camera rotation
	mat4 camRotationMatrix = getRotationMatrixZ(cameraRotation) * getRotationMatrixX(cameraTilt);
	// camera offset
	mat4 camOffsetMatrix = getTranslationMatrix(vec3(0, 0, cameraOffset));
	// combine it all to get the camera matrix
	mat4 cameraWorldMatrix = camTranslationMatrix * camRotationMatrix * camOffsetMatrix; // offset first to create a pivot point to rotate around, then rotate, then translate to the right position


	mat4 viewMatrix = inverse(cameraWorldMatrix);

	// now go from world space to camera space, by applying the inverse of the world matrix. Essentially this moves the camera back to the world origin and the vertex is moved along
	mat4 cameraSpaceMatrix = viewMatrix *  modelWorldMatrix;

	// TODO: set the world position variable to pass onto the fragment shader
	fragWorldPosition = (modelWorldMatrix * vertex_position).xyz; // sets the world position of this vertex. In the fragment shader this gets interpolated correctly automatically
	//fragNormal = VertexNormal;
	// TODO: calculate distance to camera for any fog applied in the fragment shader
	//fragDistanceToCamera = length(fragWorldPosition - cameraMatrix[3].xyz); // convert camera matrix to vec3 containing only the position


	// finally calculate the perspective projection matrix to move from camera space to screen space
	mat4 projectionMatrix = getPerspectiveMatrix(fieldOfView, aspectRatio);

	// Apply the view-projection transformation
	vec4 result = projectionMatrix * cameraSpaceMatrix * vertex_position;



	// set variables for backface culling
	//cameraViewDirection = normalize(vec3(viewMatrix[3]) - fragWorldPosition);

	return result;
}

#endif









// Fragment Shader
#ifdef PIXEL

varying vec3 fragWorldPosition; // output automatically interpolated fragment world position
//varying float fragDistanceToCamera; // used for fog
//varying vec3 fragNormal; // used for backface culling
//varying vec3 cameraViewDirection;

// lights
uniform vec3 lightPositions[8]; // non-transformed!
uniform vec3 lightColors[8];
uniform float lightRanges[8];
uniform float lightStrengths[8];
uniform vec3 ambientColor;

// TODO: I don't like the normal, additive lighting blending. I prefer a system where lights will overwrite the ambient lighting, and overlapping lights will be interpolated of sorts



// Function to convert RGB to HSL
/*
vec3 rgbToHsl(vec3 color) {
	float maxVal = max(max(color.r, color.g), color.b);
	float minVal = min(min(color.r, color.g), color.b);
	float delta = maxVal - minVal;
	
	// Lightness
	float l = (maxVal + minVal) / 2.0;
	
	// Saturation
	float s;
	if (delta == 0.0) {
		s = 0.0;
	} else {
		s = delta / (1.0 - abs(2.0 * l - 1.0));
	}
	
	// Hue
	float h;
	if (delta == 0.0) {
		h = 0.0;
	} else if (maxVal == color.r) {
		h = mod(((color.g - color.b) / delta), 6.0);
	} else if (maxVal == color.g) {
		h = ((color.b - color.r) / delta) + 2.0;
	} else {
		h = ((color.r - color.g) / delta) + 4.0;
	}
	h /= 6.0;
	
	return vec3(h, s, l);
}



vec3 hslToRgb(vec3 hsl) {
	float h = hsl.x;
	float s = hsl.y;
	float l = hsl.z;

	float c = (1.0 - abs(2.0 * l - 1.0)) * s;
	float x = c * (1.0 - abs(mod(h * 6.0, 2.0) - 1.0));
	float m = l - c / 2.0;
	
	vec3 rgb;
	
	if (h < 1.0 / 6.0) {
		rgb = vec3(c, x, 0.0);
	} else if (h < 2.0 / 6.0) {
		rgb = vec3(x, c, 0.0);
	} else if (h < 3.0 / 6.0) {
		rgb = vec3(0.0, c, x);
	} else if (h < 4.0 / 6.0) {
		rgb = vec3(0.0, x, c);
	} else if (h < 5.0 / 6.0) {
		rgb = vec3(x, 0.0, c);
	} else {
		rgb = vec3(c, 0.0, x);
	}

	return rgb + vec3(m);
}



vec3 blendColorsHSL(vec3 color1, vec3 color2, float amount) {
	vec3 hsl1 = rgbToHsl(color1);
	vec3 hsl2 = rgbToHsl(color2);

	// Interpolate hue, ensuring it's circular
	float h1 = hsl1.x;
	float h2 = hsl2.x;
	if (abs(h2 - h1) > 0.5) {
		if (h2 > h1) {
			h1 += 1.0;
		} else {
			h2 += 1.0;
		}
	}
	float h = mix(h1, h2, amount);
	h = mod(h, 1.0);  // Wrap hue around 1.0

	// Interpolate saturation and lightness linearly
	float s = mix(hsl1.y, hsl2.y, amount);
	float l = mix(hsl1.z, hsl2.z, amount);

	vec3 hslInterpolated = vec3(h, s, l);

	// Convert back to RGB
	return hslToRgb(hslInterpolated);
}
*/


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	// TODO: apply backface culling
	//if (dot(normalize(fragNormal), cameraViewDirection) > 0.0) {
	//	discard;
	//}

	// Check if a texture is applied by sampling from it
	vec4 texColor = Texel(tex, texture_coords);

	// Check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01) {
		discard;  // Discard fully transparent pixels
	}

	// lighting is done this way:
	// 1. calculate the sum of lighting on a surface pixel
	// 2. calculate the sum of lighting strengths on a surface pixel
	// 3. if the sum of strengths is at least 1 or bigger, use the sum of lighting as the final lighting on that surface pixel
	// 4. if the sum of strengths is less than 1, interpolate the lighting with the ambient lighting based on the sum of strengths
	// 5. multiply the lighting with the vertex color and the surface's applied texture
	// the reason why lighting is done this way is to make it more 'stylized' and give more control to the lighting emitted by point lights, but overlapping lights becomes trickier to handle


	vec3 lighting = vec3(0.0, 0.0, 0.0); // start with just ambient lighting on the surface
	float totalInfluence = 0;

	// add the lighting contribution of all lights to the surface
	for (int i = 0; i < 8; ++i) {
		if (lightStrengths[i] > 0) { // only consider lights with a strength above 0
			// distance to the light
			float distance = length(lightPositions[i] - fragWorldPosition);
			// attenuation factor
			float attenuation = clamp(1.0 - pow(distance / lightRanges[i], 1), 0.0, 1.0); // TODO: add a uniform for the power
			// sum up the light contributions
			lighting += lightColors[i] * lightStrengths[i] * attenuation;
			totalInfluence = totalInfluence + attenuation;
		}
	}

	vec3 finalColor = lighting;
	if (totalInfluence < 1.0) {
		finalColor = vec3(
			ambientColor.r * (1.0 - totalInfluence) + lighting.r * totalInfluence,
			ambientColor.g * (1.0 - totalInfluence) + lighting.g * totalInfluence,
			ambientColor.b * (1.0 - totalInfluence) + lighting.b * totalInfluence
		);
	}

	// TODO: interpolate the lighting towards the fog color depending on the fog thickness and how far the fragment is from the camera

	// Final color calculation
	//vec3 finalColor = lighting * texColor.rgb * color.rgb;


	// If the texture is effectively white (no texture) or the mesh has no texture applied
	// I don't think this is necessary?
	//if (texColor == vec4(1.0, 1.0, 1.0, 1.0)) {
	//	return color;  // Return the input color without modifying it
	//}

	// calculate surface lighting based on ambient and surrounding lights in range

	// Return the texture color multiplied by the input color
	return texColor * color * vec4(finalColor.x, finalColor.y, finalColor.z, 1.0);
	//return texColor;
}

#endif