extends Area2D
## Llave para abrir una jaula con candado. Se recoge al tocarla.

signal recogida

@onready var sprite_2d: Sprite2D = $Sprite2D

var tiempo : float = 0.0


func _ready() -> void:
	add_to_group("llaves")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	#La llave flota para que se note en el mapa
	tiempo += delta
	sprite_2d.position.y = sin(tiempo * 4.0) * 1.5


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.llaves += 1
		recogida.emit()
		queue_free()
