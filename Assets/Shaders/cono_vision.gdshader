shader_type canvas_item;
// Cono de visión del traficante: se desvanece con la distancia y tiene ondas que avanzan, como una linterna.
uniform float alcance = 46.0;
varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	float d = length(local) / alcance;
	float ondas = 0.82 + 0.18 * sin(d * 16.0 - TIME * 5.0);
	COLOR.a *= (1.5 - d * 1.15) * ondas * smoothstep(1.0, 0.92, d);
}
