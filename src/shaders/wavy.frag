extern number time;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
{
	vec2 resolution = vec2(1920.0,1080.0);
	float t = time / 2.0;
	float dx = sin((sc.y/resolution.y + t)*10.0) / 24.0;
	float dy = -cos((sc.x/resolution.x + t)*10.0) / 24.0;
	vec2 uv = vec2(tc.x + dx, tc.y + dy);
	vec4 pixel = Texel(texture, uv);
	pixel = 1.0 - pixel;
	pixel[3] = 1.0;
	return vec4(pixel);
}