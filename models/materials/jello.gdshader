shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;
// The jello spill wall: clear green jello. You can see through the middle,
// the edges look thicker, and soft bands wobble up and down.

uniform vec4 jello : source_color = vec4(0.655, 0.788, 0.341, 1.0);
uniform float clear = 0.16; // How see-through the middle is (lower = clearer)

void fragment() {
	// Edges facing away from the camera look thicker, like real jello.
	float edge = 1.0 - abs(dot(NORMAL, VIEW));
	float bands = 0.5 + 0.5 * sin(UV.y * 60.0 + TIME * 1.5);
	ALBEDO = jello.rgb * (0.9 + 0.2 * bands) + vec3(0.25) * pow(edge, 3.0);
	ALPHA = clamp(clear + 0.55 * pow(edge, 2.0) + 0.05 * bands, 0.0, 0.85);
}
