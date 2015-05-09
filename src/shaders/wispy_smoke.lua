return
love.graphics.newShader[[
#define TAU 6.28318530718
#define MAX_ITER 2
extern vec2 resolution;
extern number time;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
{
	float time = time * 0.2;
	vec2 uv = sc.xy / resolution.xy;
	vec2 p = mod(uv*TAU, TAU)-250.0;
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;
	for(int n = 0; n < MAX_ITER; n++)
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y/(cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c,1.4);
	vec3 colour = vec3(pow(abs(c),3.0));
	colour = clamp(colour+vec3(0.0,0.0,0.0),0.0,1.0);
	return vec4(colour,0.5);
}
]]