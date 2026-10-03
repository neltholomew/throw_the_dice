shader_type canvas_item;

uniform bool outline_on = false;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width = 8.0;

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (outline_on && color.a < 1.0) {
		vec2 step_size = TEXTURE_PIXEL_SIZE * outline_width;
		float edge = 0.0;
		for (int i = 0; i < 12; i++) {
			float angle = float(i) * TAU / 12.0;
			edge = max(edge, texture(TEXTURE, UV + vec2(cos(angle), sin(angle)) * step_size).a);
		}
		color = mix(vec4(outline_color.rgb, edge * outline_color.a), color, color.a);
	}
	COLOR = color * tint;
}
