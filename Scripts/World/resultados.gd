extends Control
## Resultados del nivel: estrellas, estadísticas y lo aprendido.
## ENTER lleva al siguiente nivel, o al título si era el último.

@export var textura_estrella : Texture2D
@export var textura_estrella_vacia : Texture2D

@onready var titulo: Label = $Panel/Cabecera/Titulo
@onready var estrellas: HBoxContainer = $Panel/Estrellas
@onready var label_rescatados: Label = $Panel/Datos/LabelRescatados
@onready var label_primer_intento: Label = $Panel/Datos/LabelPrimerIntento
@onready var label_pregunta: Label = $Panel/Datos/LabelPregunta
@onready var texto_aprendiste: Label = $Panel/CajaAprendiste/Margen/TextoAprendiste
@onready var pie: Label = $Panel/Pie


func _ready() -> void:
	Sonido.reproducir("victoria")
	var ultimo := GameManager.siguiente_escena == ""
	titulo.text = "¡MISIÓN CUMPLIDA!" if ultimo else "¡NIVEL %d COMPLETADO!" % GameManager.nivel_actual
	var total := GameManager.total_especies()
	label_rescatados.text = "Animales rescatados: %d / %d" % [GameManager.rescatados.size(), total]
	label_primer_intento.text = "Hábitat correcto al primer intento: %d / %d" % [GameManager.aciertos_primer_intento(), total]
	label_pregunta.text = "Pregunta final: " + ("correcta" if GameManager.respuesta_correcta else "incorrecta")
	texto_aprendiste.text = GameManager.aprendiste.get(GameManager.nivel_actual, "")
	pie.text = "[ENTER] volver al inicio" if ultimo else "[ENTER] siguiente nivel"
	var cantidad := GameManager.estrellas()
	Evaluacion.estrellas_totales += cantidad
	var i := 0
	for estrella in estrellas.get_children():
		estrella.texture = textura_estrella if i < cantidad else textura_estrella_vacia
		i += 1


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		if GameManager.siguiente_escena != "":
			get_tree().change_scene_to_file(GameManager.siguiente_escena)
		else:
			get_tree().change_scene_to_file("res://Scenes/World/evaluacion_final.tscn")
