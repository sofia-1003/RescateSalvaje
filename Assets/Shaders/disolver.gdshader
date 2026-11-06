shader_type canvas_item;
// El animal se disuelve en píxeles dorados al volver a su hábitat. El script anima progreso de 0 a 1.
uniform float progreso : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color_borde : source_color = vec3(1.0, 0.85, 0.3);

float azar(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float h = azar(floor(UV / TEXTURE_PIXEL_SIZE));
	if (h < progreso) {
		discard;
	}
	if (progreso > 0.0 && h < progreso + 0.22) {
		COLOR.rgb = color_borde;
	}
}
