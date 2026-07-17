shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float lens_x = 0.5;                               // screen UV x — driven by Conductor
uniform float lens_width : hint_range(0.0, 1.0) = 0.25;   // half-width of the column
uniform float lens_strength : hint_range(0.0, 1.0) = 0.4;


void fragment() {
    vec2 uv = SCREEN_UV;
    float dx = uv.x - lens_x;

    float t = clamp(abs(dx) / lens_width, 0.0, 1.0);
    float wave = 0.5 + 0.5 * cos(t * PI);                 // 1 at center, 0 at edges
    float factor = mix(1.0, 1.0 - lens_strength, wave);

    uv.x = lens_x + dx * factor;
    COLOR = texture(screen_texture, uv);
}