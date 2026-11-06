extends Area2D
## Zona del mapa que representa un hábitat. El tamaño se ajusta con su CollisionShape2D.

@export_enum("selva", "paramo", "costa", "sabana", "bosque", "cienaga", "rio", "playa", "dosel") var habitat : String = "selva"

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func centro_global() -> Vector2:
	return collision_shape_2d.global_position
