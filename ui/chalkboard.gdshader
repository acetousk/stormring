shader_type canvas_item;
// A school chalkboard: green slate with old eraser smudges and chalk dust.

uniform vec4 slate : source_color = vec4(0.18, 0.29, 0.23, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Soft noise: smooth bumps between random points.
float soft(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 p = FRAGCOORD.xy;
	float smudge = soft(p / 220.0) * 0.6 + soft(p / 70.0) * 0.4;
	// Eraser swipes: wide, faint, wavy bands.
	float swipe = 0.5 + 0.5 * sin(p.x / 55.0 + soft(p / 260.0) * 7.0);
	float grain = hash(floor(p)) * 0.025;
	vec3 col = slate.rgb + vec3(smudge * 0.05 + swipe * 0.02 + grain);
	COLOR = vec4(col, 1.0);
}
