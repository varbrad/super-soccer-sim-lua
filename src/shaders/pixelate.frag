extern vec2 resolution;
extern vec2 pixelation;
vec4 effect(vec4 c, Image t, vec2 tex_c, vec2 sc)
{
	vec2 uv = tex_c.xy;
	vec3 tc = vec3(1.0, 0.0, 0.0);
	float dx = pixelation.x*(1.0/resolution.x);
	float dy = pixelation.y*(1.0/resolution.y);
	vec2 coord = vec2(dx*floor(uv.x/dx),dy*floor(uv.y/dy));
	return Texel(t, coord);
}