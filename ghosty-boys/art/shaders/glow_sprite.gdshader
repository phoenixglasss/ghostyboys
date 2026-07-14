shader_type canvas_item;

uniform vec4 bevel_color : source_color = vec4(0.4, 0.85, 1.0, 1.0);
uniform vec4 body_color  : source_color = vec4(0.5, 0.5, 0.6, 1.0);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.1;
uniform int thickness : hint_range(1, 8) = 1;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a <= alpha_threshold) discard;

    bool is_top = true;
    for (int i = 1; i <= thickness; i++) {
        float y = UV.y - TEXTURE_PIXEL_SIZE.y * float(i);
        if (y < 0.0) break;              // off the top = nothing above = still top
        if (texture(TEXTURE, vec2(UV.x, y)).a > alpha_threshold) {
            is_top = false;
            break;
        }
    }

    COLOR = is_top ? vec4(bevel_color.rgb, tex.a * bevel_color.a)
                   : vec4(tex.rgb * body_color.rgb, tex.a * body_color.a);
}