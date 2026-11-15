shader_type canvas_item;

uniform vec3 eye_color = vec3(0.561, 0.953, 1.0);
uniform float tolerance = 0.2;
uniform vec4 calm_color : source_color = vec4(0.35, 0.75, 1.0, 1.0);
uniform vec4 corrupt_color : source_color = vec4(1.0, 0.12, 0.18, 1.0);
uniform float corruption : hint_range(0.0, 1.0) = 0.0;
uniform float glow_strength = 1.5;
uniform float glow_radius = 10.0;

float eye_mask(vec4 c) {
	return step(distance(c.rgb, eye_color), tolerance) * step(0.5, c.a);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 glow_col = mix(calm_color.rgb, corrupt_color.rgb, corruption);
	float m = eye_mask(tex);
	vec4 col = tex;
	col.rgb = mix(tex.rgb, glow_col * glow_strength, m);
	float halo = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		vec2 off = vec2(cos(a), sin(a)) * glow_radius * TEXTURE_PIXEL_SIZE;
		halo += eye_mask(texture(TEXTURE, UV + off));
	}
	halo /= 8.0;
	col.rgb += glow_col * halo * (1.0 - m) * 0.8;
	col.a = max(col.a, halo * 0.6);
	COLOR = col * COLOR;
	}
