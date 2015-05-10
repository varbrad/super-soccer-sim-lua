vec4 effect(vec4 c, Image t, vec2 tc, vec2 sc)
{
	vec4 pixel = Texel(t, tc);
	pixel = 1.0 - pixel;
	pixel[3] = 1.0;
	return pixel;
}