shader_type spatial;
// School lunchroom floor: small speckled tiles in two colors, like a checkerboard.
// Small tiles make the room look huge next to a kindergartner.

uniform vec4 tile_a : source_color = vec4(0.93, 0.89, 0.81, 1.0);
uniform vec4 tile_b : source_color = vec4(0.72, 0.85, 0.75, 1.0);
uniform float tile_size = 0.7; // meters

varying vec3 world_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 cell = floor(world_pos.xz / tile_size);
	vec3 col = mix(tile_a.rgb, tile_b.rgb, mod(cell.x + cell.y, 2.0));
	// Speckles in each tile.
	// (Tiny speckles flicker far away, so they fade out with distance.)
	float near = 1.0 - clamp(length(fwidth(world_pos.xz)) * 12.0 - 0.3, 0.0, 1.0);
	col *= 1.0 - step(0.92, hash(floor(world_pos.xz * 12.0))) * 0.22 * near;
	// Thin dark gaps between tiles.
	vec2 f = fract(world_pos.xz / tile_size);
	col *= 1.0 - step(min(f.x, f.y), 0.025) * 0.15;
	// Far away, tiles get smaller than a pixel and flicker. Fade them to their average color there.
	vec3 average = (tile_a.rgb + tile_b.rgb) * 0.5 * 0.97;
	float far = clamp(length(fwidth(world_pos.xz)) / tile_size * 1.5 - 0.15, 0.0, 1.0);
	ALBEDO = mix(col, average, far);
	ROUGHNESS = 0.3;
}
