shader_type canvas_item;

uniform bool is_end;

void fragment() {
	if (is_end) {
		vec4 text_color = texture(TEXTURE, UV);
		float color_average = (text_color.r + text_color.g + text_color.b) / 3.0;
		COLOR = vec4(color_average, color_average, color_average, text_color.a);
	}
}

