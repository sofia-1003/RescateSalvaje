extends CanvasLayer
## Ficha de la especie que se desbloquea al devolverla a su hábitat.
## Uso: await ficha.mostrar(especie)

signal cerrada

var abierta : bool = false

@onready var imagen: TextureRect = $Panel/Marco/Imagen
@onready var nombre: Label = $Panel/Nombre
@onready var habitat: Label = $Panel/Contenido/Habitat
@onready var dato: Label = $Panel/Contenido/Dato
@onready var estado: Label = $Panel/Contenido/Estado


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if abierta and Input.is_action_just_pressed("ui_accept"):
		Sonido.reproducir("click")
		abierta = false
		visible = false
		get_tree().paused = false
		cerrada.emit()


func mostrar(especie: Dictionary) -> void:
	imagen.texture = GameManager.textura_animal(especie["sprite"])
	nombre.text = String(especie["nombre"]).to_upper()
	habitat.text = "Hábitat: " + especie["habitat_nombre"]
	dato.text = "Dato: " + especie["dato"]
	estado.text = "Estado: " + especie["estado"]
	visible = true
	abierta = true
	get_tree().paused = true
	await cerrada
