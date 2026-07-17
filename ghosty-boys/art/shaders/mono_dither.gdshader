shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec3 mono_color : source_color = vec3(0.2, 1.0, 0.3);
uniform int levels : hint_range(2, 16) = 4;
uniform bool use_dither = true;
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D noise_tex : repeat_enable, filter_nearest;
uniform vec2 noise_offset = vec2(0.0);
uniform float noise_scale : hint_range(0.1, 8.0) = 1.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.15;

// --- color correction ---
uniform float cc_gain : hint_range(0.0, 3.0) = 1.0;       // multiply
uniform float cc_lift : hint_range(-0.5, 0.5) = 0.0;      // shadow offset
uniform float cc_gamma : hint_range(0.1, 3.0) = 1.0;      // >1 brightens mids
uniform float cc_contrast : hint_range(0.0, 3.0) = 1.0;   // pivots at 0.5
uniform float cc_brightness : hint_range(-1.0, 1.0) = 0.0;

// ---- scan line stuff ---
uniform float sl_freq : hint_range(0.0,1000.0) = 1.0;
uniform float sl_amp : hint_range(0.0,1.0) = 0.1;



const float bayer[16] = float[](
     0.0,  8.0,  2.0, 10.0,
    12.0,  4.0, 14.0,  6.0,
     3.0, 11.0,  1.0,  9.0,
    15.0,  7.0, 13.0,  5.0);

float get_bayer(vec2 frag) {
    int x = int(mod(frag.x, 4.0));
    int y = int(mod(frag.y, 4.0));
    return (bayer[y * 4 + x] + 0.5) / 16.0;
}

void fragment() {
    vec3 src = texture(screen_texture, SCREEN_UV).rgb;
    float lum = dot(src, vec3(0.299, 0.587, 0.114));

    // gain -> lift -> gamma -> contrast -> brightness
    lum = lum * cc_gain + cc_lift;
    lum = pow(max(lum, 0.0), 1.0 / cc_gamma);
    lum = (lum - 0.5) * cc_contrast + 0.5 + cc_brightness;
    lum = clamp(lum, 0.0, 1.0);
	
	// animated noise
    float n = texture(noise_tex, SCREEN_UV * noise_scale + noise_offset).r;
    lum = clamp(lum + (n - 0.5) * noise_amount, 0.0, 1.0);

	// scan line application
	float sl = sin(SCREEN_UV.y * sl_freq) * sl_amp;

    float steps = float(levels - 1);
    float d = use_dither ? (get_bayer(FRAGCOORD.xy) - 0.5) * dither_strength / steps : 0.0;
    float q = clamp(floor((lum + d) * steps + 0.5) / steps, 0.0, 1.0);
	
	q -= sl;

    COLOR = vec4(mono_color * q, 1.0);
}