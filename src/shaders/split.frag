extern vec2 resolution;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
{
	vec2 uv = sc.xy / resolution.xy;
	if(uv.x>0.5) return vec4(1.0,1.0,1.0,1.0);
	return vec4(1.0,0.0,1.0,1.0);
}