extends CanvasLayer
## HUD superior (vida, rescatados, animal que se lleva) y caja de mensajes.

@export var textura_corazon : Texture2D
@export var textura_corazon_vacio : Texture2D

var llevando : String = ""
var tiempo_mensaje : float = 0.0

@onready var corazones: HBoxContainer = $Fondo/Corazones
@onready var label_contador: Label = $Fondo/LabelContador
@onready var label_animal: Label = $Fondo/LabelAnimal
@onready var label_llaves: Label = $Fondo/LabelLlaves
@onready var label_contador_llaves: Label = $Fondo/LabelContadorLlaves
@onready var mensaje: Panel = $Mensaje
@onready var texto_mensaje: Label = $Mensaje/Margen/TextoMensaje


func _ready() -> void:
	mensaje.visible = false


func _process(delta: float) -> void:
	var i := 0
	for corazon in corazones.get_children():
		corazon.texture = textura_corazon if i < GameManager.vidas else textura_corazon_vacio
		i += 1
	label_contador.text = "%d / %d" % [GameManager.rescatados.size(), GameManager.total_especies()]
	label_animal.text = llevando if llevando != "" else "-"
	label_contador_llaves.text = "x%d" % GameManager.llaves

	if tiempo_mensaje > 0:
		tiempo_mensaje -= delta
		if tiempo_mensaje <= 0:
			mensaje.visible = false


#Las llaves solo se muestran en los niveles que tienen jaulas con candado
func mostrar_llaves(mostrar: bool) -> void:
	label_llaves.visible = mostrar
	label_contador_llaves.visible = mostrar


func mostrar_mensaje(texto: String, segundos: float = 4.0) -> void:
	texto_mensaje.text = texto
	mensaje.visible = true
	tiempo_mensaje = segundos
