shader_type spatial;
// Drop ceiling: big pale tiles with a thin metal grid.

uniform vec4 tile_color : source_color = vec4(0.95, 0.93, 0.88, 1.0);
uniform float tile_size = 2.4;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 f = fract(world_pos.xz / tile_size);
	float grid = step(min(f.x, f.y), 0.03);
	ALBEDO = tile_color.rgb * (1.0 - grid * 0.25);
	ROUGHNESS = 0.9;
}
