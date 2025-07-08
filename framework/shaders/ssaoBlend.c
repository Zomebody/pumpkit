
uniform Image aoTexture;
uniform Image normalsTexture;
uniform vec3 occlusionColor;

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoords) {
	float ao = Texel(aoTexture, texCoord).r;
	float aoFactor = Texel(normalsTexture, texCoord).a; // alpha channel of normal map texture encodes if AO should be applied to the fragment at that location
	ao = mix(1.0, ao, aoFactor);
	vec4 sceneColor = Texel(tex, texCoord);
	return vec4(sceneColor.rgb * ao + (1.0 - ao) * occlusionColor, sceneColor.a);
}
