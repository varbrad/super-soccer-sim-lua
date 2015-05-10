extern vec2 resolution;
vec2 get_tex_coord(float x, float y)
{
	vec2 new_sc = vec2(x, y);
	vec2 product = new_sc.xy / resolution.xy;
	product[1] = 1.0 - product[1];
	return product;
}

vec4 effect(vec4 c, Image t, vec2 tc, vec2 sc)
{
	float strength = 2;
	vec4 top = Texel(t, get_tex_coord(sc.x, sc.y - strength));
	vec4 bottom = Texel(t, get_tex_coord(sc.x, sc.y + strength));
	vec4 left = Texel(t, get_tex_coord(sc.x - strength, sc.y));
	vec4 right = Texel(t, get_tex_coord(sc.x + strength, sc.y));
	vec4 tl = Texel(t, get_tex_coord(sc.x - strength, sc.y - strength));
	vec4 tr = Texel(t, get_tex_coord(sc.x + strength, sc.y - strength));
	vec4 bl = Texel(t, get_tex_coord(sc.x - strength, sc.y + strength));
	vec4 br = Texel(t, get_tex_coord(sc.x + strength, sc.y + strength));
	vec4 center = Texel(t, tc);
	// get sum
	vec4 sum = (tl + tr + bl + br + 2.0 * top + 2.0 * left + 2.0 * right + 2.0 * bottom + 4.0 * center) / 12;
	return vec4(sum.rgb, 1.0);
}