shader_type spatial;
render_mode unshaded;

uniform vec4 bg_color: source_color;
uniform float seed = 1.0;
uniform float prob_mod = 1.0;
uniform float size = 100.0;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)) * seed) * 43758.5453123);
}

void fragment() {
	float prob = 0.9 * prob_mod;
	vec2 pos = floor(1.0 / size * FRAGCOORD.xy);
	float color = 0.0;
	float starValue = rand(pos);
	
	if (starValue > prob)
	{
		vec2 center = size * pos + vec2(size, size) * 0.5;
		float t = 0.9 + 0.1 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
		color = 1.0 - distance(FRAGCOORD.xy, center) / (0.5 * size);
		color = color * t / (abs(FRAGCOORD.y - center.y)) * t / (abs(FRAGCOORD.x - center.x));
	}
	else if (rand(SCREEN_UV.xy / 20.0) > 0.996)
	{
		float r = rand(SCREEN_UV.xy);
		float n = distance(r, 0.5);
		color = n * (0.4 * sin(TIME * (n * 5.0) + 720.0 * n) + 0.95);
	}
	ALBEDO = vec3(color);
}
