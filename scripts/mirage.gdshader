shader_type canvas_item;
// mirage shader, Reactor only

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float frequency = 50.0;
uniform float depth = 0.005;
uniform float is_active : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y * frequency + TIME) * depth * is_active;
	uv.x = clamp(uv.x, 0.0, 1.0);
	vec3 screenEffect = textureLod(SCREEN_TEXTURE, uv, 0.0).rgb;

	COLOR.rgb = screenEffect;
}
