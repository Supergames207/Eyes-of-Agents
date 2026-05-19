shader_type canvas_item;

// Pixelation
uniform vec2 pixel_count = vec2(256.0);

// OKLCH Posterization
uniform bool use_posterization = true;
uniform bool use_l = true;
uniform bool use_c = true;
uniform bool use_h = true;
uniform float steps_l : hint_range(1.0, 50.0, 1.0) = 25.0;
uniform float level_c : hint_range(0.01, 15.0) = 5.0;
uniform float level_h : hint_range(0.01, 0.1) = 0.05;

// Palette
uniform bool use_palette = true;
uniform float mix_amount : hint_range(0.0, 1.0) = 1.0;

const vec3 COLOR_PALETTE[11] = vec3[](
    vec3(0.137, 0.137, 0.137),
    vec3(0.227, 0.227, 0.227),
    vec3(0.318, 0.318, 0.318),
    vec3(0.409, 0.409, 0.409),
    vec3(0.500, 0.500, 0.500),
    vec3(0.591, 0.591, 0.591),
    vec3(0.682, 0.682, 0.682),
    vec3(0.773, 0.773, 0.773),
    vec3(0.864, 0.864, 0.864),
    vec3(0.955, 0.955, 0.955),
    vec3(1.000, 1.000, 1.000)
);

vec3 get_nearest_color(vec3 color) {
    float min_diff = 1.0;
    vec3 nearest = color;
    for (int i = 0; i < 11; i++) {
        float dist = distance(COLOR_PALETTE[i], color);
        if (dist < min_diff) {
            min_diff = dist;
            nearest = COLOR_PALETTE[i];
        }
    }
    return nearest;
}

vec3 rgb_to_oklch(vec3 rgb) {
    vec3 lin;
    lin.r = (rgb.r <= 0.04045) ? rgb.r / 12.92 : pow((rgb.r + 0.055) / 1.055, 2.4);
    lin.g = (rgb.g <= 0.04045) ? rgb.g / 12.92 : pow((rgb.g + 0.055) / 1.055, 2.4);
    lin.b = (rgb.b <= 0.04045) ? rgb.b / 12.92 : pow((rgb.b + 0.055) / 1.055, 2.4);

    float x = lin.r * 0.4124 + lin.g * 0.3576 + lin.b * 0.1805;
    float y = lin.r * 0.2126 + lin.g * 0.7152 + lin.b * 0.0722;
    float z = lin.r * 0.0193 + lin.g * 0.1192 + lin.b * 0.9505;

    float fx = (x / 0.95047 > 0.008856) ? pow(x / 0.95047, 1.0/3.0) : (7.787 * x / 0.95047 + 16.0/116.0);
    float fy = (y           > 0.008856) ? pow(y,           1.0/3.0) : (7.787 * y           + 16.0/116.0);
    float fz = (z / 1.08883 > 0.008856) ? pow(z / 1.08883, 1.0/3.0) : (7.787 * z / 1.08883 + 16.0/116.0);

    float l = 116.0 * fy - 16.0;
    float a = 500.0 * (fx - fy);
    float b = 200.0 * (fy - fz);

    float c = sqrt(a * a + b * b);
    float h = degrees(atan(b, a));
    if (h < 0.0) h += 360.0;

    return vec3(l / 100.0, c / 100.0, h);
}

vec3 oklch_to_rgb(vec3 lch) {
    float l = lch.x * 100.0;
    float c = lch.y * 100.0;
    float h_rad = radians(lch.z);

    float a_lab = cos(h_rad) * c;
    float b_lab = sin(h_rad) * c;

    float fy = (l + 16.0) / 116.0;
    float fx = a_lab / 500.0 + fy;
    float fz = fy - b_lab / 200.0;
    vec3 f = vec3(fx, fy, fz);
    vec3 f3 = f * f * f;

    vec3 mask = step(vec3(0.008856), f3);
    vec3 xyz = mask * f3 + (1.0 - mask) * ((f - vec3(16.0/116.0)) / 7.787);
    xyz *= vec3(0.95047, 1.0, 1.08883);

    float r = xyz.x *  3.2406 + xyz.y * -1.5372 + xyz.z * -0.4986;
    float g = xyz.x * -0.9689 + xyz.y *  1.8758 + xyz.z *  0.0415;
    float b = xyz.x *  0.0557 + xyz.y * -0.2040 + xyz.z *  1.0570;
    vec3 lin = vec3(r, g, b);

    vec3 mask_rgb = step(lin, vec3(0.0031308));
    vec3 srgb = mix(1.055 * pow(lin, vec3(1.0/2.4)) - 0.055, lin * 12.92, mask_rgb);

    return clamp(srgb, 0.0, 1.0);
}

float posterize(float value, float levels) {
    return round(value * levels) / levels;
}

void fragment() {
    // Pixelation
    vec2 uv = UV * pixel_count;
    vec2 pixel_fract = fract(uv);
    vec2 center_uv = floor(uv) + clamp(pixel_fract / fwidth(uv), 0.0, 1.0);
    vec4 sampled = texture(TEXTURE, center_uv / pixel_count);

    vec3 col = sampled.rgb;

    // OKLCH posterization
    if (use_posterization) {
        vec3 lch = rgb_to_oklch(col);
        if (use_l) lch.r = posterize(lch.r, steps_l);
        if (use_c) lch.g = posterize(lch.g, level_c);
        if (use_h) lch.b = posterize(lch.b, level_h);
        col = oklch_to_rgb(lch);
    }

    // Palette
    if (use_palette) {
        vec3 nearest = get_nearest_color(col);
        col = mix(col, nearest, mix_amount);
    }

    COLOR = vec4(col, sampled.a);
}