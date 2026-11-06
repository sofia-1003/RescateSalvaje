extends Control
## Pantalla de título. ENTER empieza la partida.

var tiempo : float = 0.0

@onready var label_enter: Label = $LabelEnter


func _ready() -> void:
	Sonido.tocar_musica("musica")
	#Con "-- --juego" se entra directo a la partida (útil para probar)
	if "--juego" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/World/nivel_1.tscn")
	elif "--nivel2" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/World/nivel_2.tscn")
	elif "--nivel3" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/World/nivel_3.tscn")


func _process(delta: float) -> void:
	tiempo += delta
	label_enter.visible = fmod(tiempo, 1.0) < 0.7
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		get_tree().change_scene_to_file("res://Scenes/World/evaluacion_inicial.tscn")


#F2: panel del docente con el análisis de resultados
func _input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo and evento.physical_keycode == KEY_F2:
		get_tree().change_scene_to_file("res://Scenes/World/panel_resultados.tscn")
