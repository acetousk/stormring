shader_type spatial;
// Painted cinderblock school wall: green on the bottom, cream on top, a red stripe between.

uniform vec4 low_color : source_color = vec4(0.72, 0.85, 0.75, 1.0);
uniform vec4 high_color : source_color = vec4(1.0, 0.945, 0.839, 1.0);
uniform vec4 stripe_color : source_color = vec4(0.902, 0.224, 0.275, 1.0);
uniform float stripe_height = 9.0; // meters
uniform vec2 block = vec2(1.2, 0.6); // one block, in meters

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float y = world_pos.y;
	vec3 col = y < stripe_height ? low_color.rgb : high_color.rgb;
	if (y > stripe_height && y < stripe_height + 0.9) {
		col = stripe_color.rgb;
	}
	// Blocks: every other row shifts by half a block.
	float along = world_pos.x + world_pos.z;
	float row = floor(y / block.y);
	vec2 f = fract(vec2(along / block.x + mod(row, 2.0) * 0.5, y / block.y));
	col *= 1.0 - step(min(f.x, f.y), 0.04) * 0.12;
	ALBEDO = col;
	ROUGHNESS = 0.6;
}
