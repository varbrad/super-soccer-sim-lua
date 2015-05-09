return
love.graphics.newShader[[
extern vec2 resolution;
extern number time;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 effect(vec4 love_color, Image texture, vec2 tc, vec2 sc)
{
	vec2 position = ( sc.xy / resolution.xy );
	float n = rand(vec2(position.x * time, position.y * time)); 
	return vec4(vec3(n), 0.4);
}
]]