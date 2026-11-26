shader_type canvas_item;
// Chalk writing: rubs out tiny bits of each letter, like chalk on a board.

uniform float grit = 0.35; // 0 = clean letters, 1 = mostly rubbed out

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float dust = hash(floor(FRAGCOORD.xy / 1.5));
	float streak = hash(vec2(floor(FRAGCOORD.y / 2.0), 3.0));
	c.a *= step(grit * 0.7, dust) * (0.7 + 0.3 * streak);
	COLOR = c;
}
