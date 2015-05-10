vec4 tint = vec4(1.0, 1.0, 1.0, 1.0);
vec4 effect(vec4 c, Image t, vec2 tc, vec2 sc)
{
	c = Texel(t, tc);
	float luma = dot(vec3(0.299, 0.587, 0.114), c.rgb);
	return mix(c, luma * tint, 1.0);
}