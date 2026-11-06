extends CanvasLayer
## Pantalla cuando los traficantes atrapan al jugador 3 veces. ENTER reinicia.

func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		get_tree().reload_current_scene()


func mostrar() -> void:
	visible = true
	get_tree().paused = true
