shader_type canvas_item;
// Destello diagonal que recorre la llave para que se note en el mapa.
uniform float velocidad = 0.6;

void fragment() {
	float x = UV.x + UV.y;
	float banda = fract(TIME * velocidad) * 4.0 - 1.0;
	float b = smoothstep(0.22, 0.0, abs(x - banda));
	COLOR.rgb += vec3(0.8, 0.8, 0.6) * b;
}
