shader_type canvas_item;
render_mode unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float width : hint_range(0.0, 8.0, 1.0) = 1.0;

void vertex() {
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 s = (tex_size + width * 2.0) / tex_size;
	VERTEX *= s;
	UV = (UV - 0.5) * s + 0.5;
}

float alpha_at(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return 0.0;
	}
	return texture(tex, uv).a;
}

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE * width;

	float a = alpha_at(TEXTURE, UV);

	float n = 0.0;
	n = max(n, alpha_at(TEXTURE, UV + vec2( ps.x, 0.0)));
	n = max(n, alpha_at(TEXTURE, UV + vec2(-ps.x, 0.0)));
	n = max(n, alpha_at(TEXTURE, UV + vec2(0.0,  ps.y)));
	n = max(n, alpha_at(TEXTURE, UV + vec2(0.0, -ps.y)));
	n = max(n, alpha_at(TEXTURE, UV + vec2( ps.x,  ps.y)));
	n = max(n, alpha_at(TEXTURE, UV + vec2(-ps.x, -ps.y)));
	n = max(n, alpha_at(TEXTURE, UV + vec2( ps.x, -ps.y)));
	n = max(n, alpha_at(TEXTURE, UV + vec2(-ps.x,  ps.y)));

	vec4 base = texture(TEXTURE, UV) * COLOR;
	base.a = a * COLOR.a;

	COLOR = mix(vec4(outline_color.rgb, outline_color.a * n), base, base.a);
}