#pragma language glsl3




// coloring
uniform vec3 ambientColor;
uniform float meshBrightness;
uniform vec3 meshColor;

// textures
uniform Image meshTexture;







void effect() {

	vec4 color = VaryingColor;
	color = vec4(color.x * meshColor.x, color.y * meshColor.y, color.z * meshColor.z, color.w);
	
	
	if (love_PixelCoord.x < 0 || love_PixelCoord.x > love_ScreenSize.x || love_PixelCoord.y < 0 || love_PixelCoord.y > love_ScreenSize.y) {
		discard;
	}
	
	
	vec2 texture_coords = VaryingTexCoord.xy;

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
	resultingColor = resultingColor * resultingLighting;


	// debug normal maps. This shows fragment normals in world-space
	//resultingColor = resultingColor * 0.00001 + vec4((normalMapNormalWorld.xyz + vec3(1.0)) / 2.0, 1.0);
	love_Canvases[0] = resultingColor;

}


