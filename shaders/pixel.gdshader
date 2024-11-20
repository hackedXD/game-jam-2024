shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

const int pixel_size = 8; //resolution must be divisible by pixel_size

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	ALBEDO = texture(screen_texture, vec2(x, y) / VIEWPORT_SIZE).xyz;
}