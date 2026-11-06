extends CharacterBody2D
## Traficante: patrulla los puntos de su ruta (se editan en el Inspector).
## Si ve al jugador dentro de su cono de visión lo persigue unos segundos.

signal atrapo_jugador

@export var SPEED_PATRULLA : float = 28.0
@export var SPEED_PERSECUCION : float = 50.0
@export var ruta : PackedVector2Array = []     # puntos de patrulla (coordenadas del nodo Mundo)

#Dificultad: se puede ajustar por traficante en el Inspector
@export var ALCANCE_VISION : float = 46.0
@export var ANGULO_VISION : float = 35.0       # grados hacia cada lado
@export var TIEMPO_PERSECUCION : float = 3.0

const DISTANCIA_ATRAPAR := 10.0

var jugador: Player
var indice : int = 0
var persiguiendo : bool = false
var tiempo_restante : float = 0.0
var facing_direction := Vector2.RIGHT
var camino_regreso : Array[Vector2] = []   # migas de pan para volver a la ruta tras perseguir
var tiempo_atascado : float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var cono_vision: Polygon2D = $ConoVision
@onready var alerta: Label = $Alerta
@onready var linea_vista: RayCast2D = $LineaVista


func _ready() -> void:
	add_to_group("traficantes")
	alerta.visible = false
	if not ruta.is_empty():
		position = ruta[0]
	crear_cono()


#Dibuja el cono de visión con el alcance y el ángulo de este traficante
func crear_cono() -> void:
	var puntos := PackedVector2Array([Vector2.ZERO])
	for i in 9:
		var angulo := deg_to_rad(-ANGULO_VISION + 2.0 * ANGULO_VISION * i / 8.0)
		puntos.append(Vector2.RIGHT.rotated(angulo) * ALCANCE_VISION)
	cono_vision.polygon = puntos
	#Cada traficante usa su propia copia del shader, con su alcance
	if cono_vision.material:
		cono_vision.material = cono_vision.material.duplicate()
		cono_vision.material.set_shader_parameter("alcance", ALCANCE_VISION)


func _physics_process(delta: float) -> void:
	if jugador == null or ruta.is_empty():
		return
	var hacia_jugador := jugador.global_position - global_position

	if not persiguiendo and not jugador.invulnerable and puede_ver(hacia_jugador):
		persiguiendo = true
		tiempo_restante = TIEMPO_PERSECUCION
		Sonido.reproducir("alerta", -4.0)

	if persiguiendo:
		tiempo_restante -= delta
		if tiempo_restante <= 0 or hacia_jugador.length() > 110 or jugador.invulnerable:
			dejar_de_perseguir()
		#Guarda el camino recorrido para poder volver por el mismo lugar
		if camino_regreso.is_empty() or position.distance_to(camino_regreso.back()) > 8:
			camino_regreso.append(position)
		velocity = hacia_jugador.normalized() * SPEED_PERSECUCION
	elif not camino_regreso.is_empty():
		#Regresa a su ruta deshaciendo el camino de la persecución
		var hacia_miga : Vector2 = camino_regreso.back() - position
		if hacia_miga.length() < 2:
			camino_regreso.pop_back()
		velocity = hacia_miga.normalized() * SPEED_PATRULLA
	else:
		var hacia_punto := ruta[indice] - position
		if hacia_punto.length() < 2:
			indice = (indice + 1) % ruta.size()
		velocity = hacia_punto.normalized() * SPEED_PATRULLA

	if velocity.length() > 0.1:
		facing_direction = velocity.normalized()
	actualizar_animacion()
	var antes := position
	move_and_slide()
	revisar_atasco(antes, delta)

	#El cono de visión gira hacia donde mira y se pone más rojo al perseguir
	cono_vision.rotation = facing_direction.angle()
	cono_vision.color = Color(1, 0.15, 0.15, 0.6) if persiguiendo else Color(1, 0.3, 0.25, 0.36)
	alerta.visible = persiguiendo

	if hacia_jugador.length() < DISTANCIA_ATRAPAR and not jugador.invulnerable:
		atrapo_jugador.emit()


func actualizar_animacion() -> void:
	if absf(facing_direction.x) > absf(facing_direction.y):
		animated_sprite_2d.play("walk_right" if facing_direction.x > 0 else "walk_left")
	else:
		animated_sprite_2d.play("walk_down" if facing_direction.y > 0 else "walk_up")


func puede_ver(hacia_jugador: Vector2) -> bool:
	if hacia_jugador.length() > ALCANCE_VISION:
		return false
	if absf(facing_direction.angle_to(hacia_jugador)) > deg_to_rad(ANGULO_VISION):
		return false
	#Un árbol o una roca en medio bloquean la vista
	linea_vista.target_position = hacia_jugador
	linea_vista.force_raycast_update()
	return not linea_vista.is_colliding()


func dejar_de_perseguir() -> void:
	persiguiendo = false
	alerta.visible = false


#Si choca con algo y no avanza durante medio segundo, cambia de objetivo para no quedarse trabado
func revisar_atasco(antes: Vector2, delta: float) -> void:
	if velocity.length() > 0.1 and position.distance_to(antes) < velocity.length() * delta * 0.25:
		tiempo_atascado += delta
	else:
		tiempo_atascado = 0.0
	if tiempo_atascado < 0.5:
		return
	tiempo_atascado = 0.0
	if persiguiendo:
		dejar_de_perseguir()
	elif not camino_regreso.is_empty():
		camino_regreso.pop_back()
	else:
		indice = (indice + 1) % ruta.size()
