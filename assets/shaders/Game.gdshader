shader_type canvas_item;

uniform float speed : hint_range(0.0, 1.0) = 0.06;
uniform float grid_size : hint_range(10.0, 200.0) = 55.0;
uniform float line_thickness : hint_range(0.0, 0.1) = 0.025;
uniform float perspective : hint_range(0.0, 3.0) = 1.4;
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 0.25, 0.3);
uniform vec4 bg_color : source_color = vec4(0.0, 0.015, 0.0, 1.0);
uniform float scan_speed : hint_range(0.0, 1.0) = 0.18;
uniform float scan_brightness : hint_range(0.0, 1.0) = 0.12;

void fragment() {
    vec2 uv = UV - vec2(0.5);

    float depth = uv.y * perspective;
    uv.x /= (1.0 + depth * 0.5);
    uv += vec2(0.5);
    uv.y += TIME * speed;

    vec2 grid = fract(uv * grid_size);
    float line = step(1.0 - line_thickness, grid.x) + step(1.0 - line_thickness, grid.y);
    line = clamp(line, 0.0, 1.0);

    float scan = fract(TIME * scan_speed);
    float scan_line = smoothstep(0.0, 0.015, scan - UV.y) * smoothstep(0.0, 0.08, UV.y - scan + 0.08);
    float glow = scan_line * scan_brightness;

    vec4 col = mix(bg_color, line_color, line);
    col.rgb += vec3(0.0, glow, glow * 0.3);
    COLOR = col;
}
