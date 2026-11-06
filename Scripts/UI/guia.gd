extends CanvasLayer
## Guía de campo (tecla G): muestra las especies rescatadas y pistas de las que faltan.

@onready var entradas: VBoxContainer = $Panel/Entradas


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("GUIA") or Input.is_action_just_pressed("ui_accept"):
			visible = false
			get_tree().paused = false
	elif not get_tree().paused and Input.is_action_just_pressed("GUIA"):
		abrir()


func abrir() -> void:
	var i := 0
	for entrada in entradas.get_children():
		var especie : Dictionary = GameManager.especies_del_nivel()[i]
		var rescatado := GameManager.esta_rescatado(especie["id"])
		entrada.get_node("Imagen").texture = GameManager.textura_animal(especie["sprite"], not rescatado)
		entrada.get_node("Textos/Nombre").text = especie["nombre"] if rescatado else "???"
		var detalle : Label = entrada.get_node("Textos/Detalle")
		if rescatado:
			detalle.text = "Hábitat: %s. %s" % [especie["habitat_nombre"], especie["dato"]]
			detalle.add_theme_color_override("font_color", Color("#7cfc00"))
		else:
			detalle.text = "Pista: " + especie["pista"]
			detalle.add_theme_color_override("font_color", Color("#bbbbbb"))
		i += 1
	visible = true
	get_tree().paused = true
	Sonido.reproducir("blip")
