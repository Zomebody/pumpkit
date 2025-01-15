
uniform Image aoTexture;
uniform vec3 occlusionColor;

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoords) {
	float ao = Texel(aoTexture, texCoord).r;
	vec4 sceneColor = Texel(tex, texCoord);
	return vec4(sceneColor.rgb * ao + (1.0 - ao) * occlusionColor, sceneColor.a);
}
