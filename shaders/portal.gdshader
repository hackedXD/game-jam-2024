shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D source: source_color;

void fragment() {
	ALBEDO = texture(source, SCREEN_UV).rgb;
}