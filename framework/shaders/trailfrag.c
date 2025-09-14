#pragma language glsl3




// coloring
uniform vec3 ambientColor;
uniform float meshBrightness;
uniform vec3 meshColor;

// textures
uniform Image meshTexture;

uniform bool blends;
varying vec2 texCoords;







void effect() {

	vec4 color = VaryingColor;
	color = vec4(color.x * meshColor.x, color.y * meshColor.y, color.z * meshColor.z, color.w);
	
	
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	
	
	vec2 texture_coords = texCoords;

	vec4 texColor = Texel(meshTexture, texture_coords);
	
	
	// check if the alpha of the texture color is below a threshold
	if (texColor.a < 0.01) {
		discard;  // discard fully transparent pixels
	}


	// ended up implementing a very basic naive additive lighting system because it doesn't have any weird edge-cases
	vec3 lighting = ambientColor; // start with just ambient lighting on the surface

	
	
	//set the color on the main canvas. Apply mesh brightness here as well. Higher brightness means less affected by ambient color
	vec4 resultingColor = texColor * color; // mix color towards fresnel color
	vec4 resultingLighting = mix(vec4(lighting.xyz, 1.0), vec4(1.0, 1.0, 1.0, 1.0), meshBrightness); // mix lighting based on mesh brightness
	vec4 litColor = resultingColor * resultingLighting;


	
	//love_Canvases[0] = resultingColor;

	if (blends) {
		// in this case, blend mode is set to additive and two canvases are used (vfxCanvas1, vfxCanvas2)
		love_Canvases[0] = vec4(litColor.r * litColor.a, litColor.g * litColor.a, litColor.b * litColor.a, 1.0);
		// for red, simply add '1' to red to count the number of fragments being written
		// for green, square the alpha to give a higher priority
		love_Canvases[1] = vec4(1.0, litColor.a, 1.0, 1.0);
	} else {
		// in this case, blend mode is set to the default (alpha) one and the output canvase is the RenderCanvas
		love_Canvases[0] = litColor;
	}

}


