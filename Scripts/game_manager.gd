extends Node
## Autoload "GameManager": datos de las especies y estadísticas del nivel actual.

const VIDAS_MAXIMAS := 3
const TEXTURA_ANIMALES := preload("res://Assets/animales.png")

var especies := [
	# ---------------------------------------------------------- Nivel 1: selva, páramo y costa
	{
		"id": "guacamaya", "nivel": 1, "nombre": "Guacamaya", "sprite": 0,
		"habitat": "selva", "habitat_nombre": "Selva",
		"dato": "Come frutos y dispersa semillas: ayuda a que el bosque vuelva a crecer.",
		"estado": "Amenazada por el tráfico de mascotas",
		"pista": "La guacamaya necesita árboles altos y frutos. ¡Busca la SELVA!",
	},
	{
		"id": "oso", "nivel": 1, "nombre": "Oso de anteojos", "sprite": 1,
		"habitat": "paramo", "habitat_nombre": "Páramo y bosque andino",
		"dato": "Es el único oso de Sudamérica. Vive en las montañas frías.",
		"estado": "Vulnerable",
		"pista": "El oso de anteojos vive en las montañas frías, entre frailejones. ¡Busca el PÁRAMO!",
	},
	{
		"id": "carey", "nivel": 1, "nombre": "Tortuga carey", "sprite": 2,
		"habitat": "costa", "habitat_nombre": "Costa y arrecifes",
		"dato": "La cazan por su caparazón. Pone sus huevos en la arena de la playa.",
		"estado": "En peligro crítico",
		"pista": "La tortuga carey vive en el mar y anida en la arena. ¡Busca la COSTA!",
	},
	# ---------------------------------------------------------- Nivel 2: los Llanos
	{
		"id": "oso_palmero", "nivel": 2, "nombre": "Oso palmero", "sprite": 4,
		"habitat": "sabana", "habitat_nombre": "Sabana de los Llanos",
		"dato": "No tiene dientes: atrapa hormigas y termitas con su lengua larga y pegajosa.",
		"estado": "Vulnerable",
		"pista": "El oso palmero vive en las llanuras abiertas, entre pastos y palmas. ¡Busca la SABANA!",
	},
	{
		"id": "jaguar", "nivel": 2, "nombre": "Jaguar", "sprite": 5,
		"habitat": "bosque", "habitat_nombre": "Bosque de galería",
		"dato": "Es el felino más grande de América y un excelente nadador.",
		"estado": "Casi amenazado",
		"pista": "El jaguar necesita bosque espeso para esconderse y cazar. ¡Busca el BOSQUE!",
	},
	{
		"id": "manati", "nivel": 2, "nombre": "Manatí", "sprite": 6,
		"habitat": "cienaga", "habitat_nombre": "Ríos y ciénagas",
		"dato": "Es herbívoro: come plantas acuáticas y ayuda a mantener sanos los ríos.",
		"estado": "En peligro",
		"pista": "El manatí vive en el agua dulce de ríos y ciénagas. ¡Busca la CIÉNAGA!",
	},
	# ---------------------------------------------------------- Nivel 3: la Amazonía de noche
	{
		"id": "delfin", "nivel": 3, "nombre": "Delfín rosado", "sprite": 7,
		"habitat": "rio", "habitat_nombre": "Ríos amazónicos",
		"dato": "Es el delfín de río más grande del mundo y se orienta con ecolocalización.",
		"estado": "En peligro",
		"pista": "El delfín rosado vive en el agua dulce del río. ¡Llévalo al MUELLE!",
	},
	{
		"id": "charapa", "nivel": 3, "nombre": "Tortuga charapa", "sprite": 8,
		"habitat": "playa", "habitat_nombre": "Playas de los ríos",
		"dato": "Pone sus huevos en las playas de arena del río. La caza y el robo de sus huevos la tienen en peligro.",
		"estado": "En peligro crítico en Colombia",
		"pista": "La charapa anida en las playas de arena del río. ¡Busca la PLAYA!",
	},
	{
		"id": "churuco", "nivel": 3, "nombre": "Mono churuco", "sprite": 9,
		"habitat": "dosel", "habitat_nombre": "Dosel de la selva",
		"dato": "Vive en lo alto de los árboles y usa su cola como una quinta mano.",
		"estado": "Vulnerable",
		"pista": "El mono churuco vive en lo alto de los árboles más grandes. ¡Busca el DOSEL de la selva!",
	},
]

# Lo que se muestra en "APRENDISTE" al terminar cada nivel
var aprendiste := {
	1: "Cada especie necesita su propio hábitat. Los animales silvestres no son mascotas: si ves tráfico de fauna, denúncialo.",
	2: "Los Llanos tienen sabanas, ríos y bosques, y cada uno es el hogar de especies distintas. Comprar productos de fauna silvestre alimenta la caza ilegal.",
	3: "En la Amazonía el río, sus playas y la selva están conectados: si uno se daña, sufren todos. Comprar huevos o carne de fauna silvestre pone en peligro a especies únicas.",
}

var nivel_actual := 1
var siguiente_escena := ""     # la escena que viene después de los resultados
var vidas := VIDAS_MAXIMAS
var llaves := 0
var rescatados: Array = []     # ids de las especies devueltas a su hábitat
var fallos := {}               # id -> veces que se eligió un hábitat incorrecto
var respuesta_correcta := false


func reiniciar(nivel: int) -> void:
	nivel_actual = nivel
	vidas = VIDAS_MAXIMAS
	llaves = 0
	rescatados.clear()
	fallos.clear()
	respuesta_correcta = false


func especies_del_nivel() -> Array:
	return especies.filter(func(e): return e["nivel"] == nivel_actual)


func buscar_especie(id: String) -> Dictionary:
	for especie in especies:
		if especie["id"] == id:
			return especie
	return {}


## Recorta el animal de Assets/animales.png (fila 1 = silueta gris)
func textura_animal(indice: int, silueta: bool = false) -> AtlasTexture:
	var textura := AtlasTexture.new()
	textura.atlas = TEXTURA_ANIMALES
	textura.region = Rect2(indice * 16, 16 if silueta else 0, 16, 16)
	return textura


func registrar_fallo(id: String) -> void:
	fallos[id] = fallos.get(id, 0) + 1


func registrar_rescate(id: String) -> void:
	if not rescatados.has(id):
		rescatados.append(id)


func esta_rescatado(id: String) -> bool:
	return rescatados.has(id)


func total_especies() -> int:
	return especies_del_nivel().size()


func aciertos_primer_intento() -> int:
	var total := 0
	for id in rescatados:
		if fallos.get(id, 0) == 0:
			total += 1
	return total


func estrellas() -> int:
	var total := 1
	if aciertos_primer_intento() >= 2:
		total += 1
	if respuesta_correcta:
		total += 1
	return total
