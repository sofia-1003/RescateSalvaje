class_name Player
extends CharacterBody2D

#La escena del juego escucha esta señal para abrir jaulas
signal interactuar

@export var SPEED : float = 70.0
var facing_direction := Vector2.DOWN
var can_move: bool = true
var invulnerable: bool = false
var tiempo_invulnerable: float = 0.0
var animal_actual: Node2D = null     # animal rescatado que lo sigue
var tiempo_paso: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	actualizar_parpadeo(delta)

	if not can_move:
		velocity = Vector2.ZERO
		animated_sprite_2d.pause()
		return

	if Input.is_action_just_pressed("INTERACTUAR"):
		interactuar.emit()

	var direction = Input.get_vector(
		"IZQUIERDA",
		"DERECHA",
		"ARRIBA",
		"ABAJO")
	velocity = direction * SPEED

	if direction == Vector2.ZERO:
		if facing_direction == Vector2.UP:
			animated_sprite_2d.play("walk_up")
		elif facing_direction == Vector2.DOWN:
			animated_sprite_2d.play("walk_down")
		elif facing_direction == Vector2.LEFT:
			animated_sprite_2d.play("walk_left")
		elif facing_direction == Vector2.RIGHT:
			animated_sprite_2d.play("walk_right")
		animated_sprite_2d.pause()
		return

	#Validar la dirección hacia donde se mueve el personaje
	if direction.x > 0:
		facing_direction = Vector2.RIGHT
		animated_sprite_2d.play("walk_right")
	elif direction.x < 0:
		facing_direction = Vector2.LEFT
		animated_sprite_2d.play("walk_left")
	elif direction.y > 0:
		facing_direction = Vector2.DOWN
		animated_sprite_2d.play("walk_down")
	elif direction.y < 0:
		facing_direction = Vector2.UP
		animated_sprite_2d.play("walk_up")

	move_and_slide()

	#Sonido de pasos mientras camina
	tiempo_paso -= delta
	if tiempo_paso <= 0:
		tiempo_paso = 0.28
		Sonido.reproducir("paso", -14.0, randf_range(0.85, 1.15))


func volverse_invulnerable(segundos: float) -> void:
	invulnerable = true
	tiempo_invulnerable = segundos
	#Destello rojo con el shader golpe.gdshader
	var material_golpe := animated_sprite_2d.material as ShaderMaterial
	if material_golpe:
		material_golpe.set_shader_parameter("destello", 1.0)
		create_tween().tween_property(material_golpe, "shader_parameter/destello", 0.0, 0.5)


func actualizar_parpadeo(delta: float) -> void:
	if not invulnerable:
		return
	tiempo_invulnerable -= delta
	animated_sprite_2d.visible = int(tiempo_invulnerable * 10) % 2 == 0
	if tiempo_invulnerable <= 0:
		invulnerable = false
		animated_sprite_2d.visible = true
