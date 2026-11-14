shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform float additive_mix : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
    vec4 base = COLOR;
    vec3 replaced = mix(base.rgb, flash_color.rgb, flash_amount * flash_color.a);
    vec3 added = base.rgb + flash_color.rgb * flash_amount * flash_color.a;
    COLOR = vec4(mix(replaced, added, additive_mix), base.a);
}
