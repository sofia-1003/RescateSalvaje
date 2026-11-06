extends Node2D
## Jaula del campamento. En el Inspector se elige qué especie tiene adentro.

signal intento_abrir(jaula: Node2D)

@export_enum("guacamaya", "oso", "carey", "oso_palmero", "jaguar", "manati", "delfin", "charapa", "churuco") var especie_id : String = "guacamaya"
@export var necesita_llave : bool = false   # jaula con candado: se abre con una llave del mapa

const DISTANCIA_ABRIR := 20.0

var especie : Dictionary
var jugador : Node2D
var abierta : bool = false

@onready var animal: Sprite2D = $Animal
@onready var barras: Sprite2D = $Barras
@onready var aviso: Label = $Aviso


func _ready() -> void:
	especie = GameManager.buscar_especie(especie_id)
	animal.texture = GameManager.textura_animal(especie["sprite"])
	aviso.visible = false
	if necesita_llave:
		aviso.text = "[E] Abrir (llave)"


func _process(_delta: float) -> void:
	var cerca := not abierta and jugador != null \
		and global_position.distance_to(jugador.global_position) < DISTANCIA_ABRIR
	aviso.visible = cerca


func esta_cerca(posicion: Vector2) -> bool:
	return not abierta and global_position.distance_to(posicion) < DISTANCIA_ABRIR


func abrir() -> void:
	abierta = true
	animal.visible = false
	barras.frame = 1
	aviso.visible = false


#Si atrapan al jugador, el animal vuelve a su jaula
func cerrar() -> void:
	abierta = false
	animal.visible = true
	barras.frame = 0
