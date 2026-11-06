extends Node2D
## Animal liberado de su jaula. Sigue al jugador hasta llegar a su hábitat.

const DISTANCIA_SEGUIR := 14.0
const VELOCIDAD := 85.0

var especie : Dictionary
var jaula : Node2D
var objetivo : Node2D
var tiempo : float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.texture = GameManager.textura_animal(especie["sprite"])


func _process(delta: float) -> void:
	if objetivo == null:
		return
	if global_position.distance_to(objetivo.global_position) > DISTANCIA_SEGUIR:
		global_position = global_position.move_toward(objetivo.global_position, VELOCIDAD * delta)
		tiempo += delta
		sprite_2d.position.y = -absf(sin(tiempo * 14.0)) * 1.5
		sprite_2d.flip_h = objetivo.global_position.x < global_position.x
	else:
		sprite_2d.position.y = 0


#El animal corre hacia su hábitat y desaparece
func liberar(destino: Vector2) -> void:
	objetivo = null
	var tween = create_tween()
	tween.tween_property(self, "global_position", destino, 0.6)
	#El animal se disuelve en píxeles dorados (shader disolver.gdshader)
	sprite_2d.material = sprite_2d.material.duplicate()
	sprite_2d.material.set_shader_parameter("progreso", 0.0)
	tween.parallel().tween_property(sprite_2d.material, "shader_parameter/progreso", 1.0, 0.8)
	await tween.finished
	queue_free()
