extends CanvasLayer
## Pregunta final sobre el tráfico de fauna. Las opciones se editan en el Inspector.

@export var opciones : PackedStringArray = []
@export var correcta : int = 1
@export var explicaciones : PackedStringArray = []    # una por opción
@export_multiline var contexto : String = "Ya de vuelta en el pueblo, un vendedor te dice:"
@export_multiline var frase : String = "\"¡Lleva este loro, es barato!\""
@export var sprite_animal : int = 3    # columna de Assets/animales.png que se muestra en el recuadro

var estado : String = ""    # "" | eligiendo | respondida
var opcion : int = 0
var orden : Array = []      # orden mezclado de las opciones
var cuadro_apertura : int = -1   # evita que el ENTER que cerró la ficha responda la pregunta

@onready var labels_opciones: VBoxContainer = $Panel/Contenido/Opciones
@onready var retro: Label = $Panel/Contenido/Retro
@onready var pie: Label = $Panel/Contenido/Pie
@onready var label_contexto: Label = $Panel/Contenido/Contexto
@onready var label_frase: Label = $Panel/Contenido/Frase
@onready var imagen: TextureRect = $Panel/JaulaLoro/Imagen


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if Engine.get_process_frames() == cuadro_apertura:
		return
	match estado:
		"eligiendo":
			if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ARRIBA"):
				opcion = (opcion + opciones.size() - 1) % opciones.size()
				actualizar_opciones()
			elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ABAJO"):
				opcion = (opcion + 1) % opciones.size()
				actualizar_opciones()
			elif Input.is_action_just_pressed("ui_accept"):
				responder()
		"respondida":
			if Input.is_action_just_pressed("ui_accept"):
				get_tree().paused = false
				get_tree().change_scene_to_file("res://Scenes/World/resultados.tscn")


func mostrar() -> void:
	label_contexto.text = contexto
	label_frase.text = frase
	imagen.texture = GameManager.textura_animal(sprite_animal)
	orden = range(opciones.size())
	orden.shuffle()
	opcion = 0
	retro.text = ""
	pie.text = "Flechas: elegir    ENTER: responder"
	actualizar_opciones()
	visible = true
	estado = "eligiendo"
	cuadro_apertura = Engine.get_process_frames()
	get_tree().paused = true


func actualizar_opciones() -> void:
	var letras := ["A", "B", "C", "D"]
	var i := 0
	for label in labels_opciones.get_children():
		label.visible = i < opciones.size()
		if i < opciones.size():
			var marcada := i == opcion
			label.text = "%s %s) %s" % [">" if marcada else " ", letras[i], opciones[orden[i]]]
			label.add_theme_color_override("font_color", Color("#7cfc00") if marcada else Color("#aaaaaa"))
		i += 1


func responder() -> void:
	var elegida : int = orden[opcion]
	var acerto := elegida == correcta
	GameManager.respuesta_correcta = acerto
	Sonido.reproducir("acierto" if acerto else "error")
	retro.text = explicaciones[elegida] if elegida < explicaciones.size() else ""
	retro.add_theme_color_override("font_color", Color("#7cfc00") if acerto else Color("#ff7060"))
	pie.text = "[ENTER] ver resultados"
	estado = "respondida"
