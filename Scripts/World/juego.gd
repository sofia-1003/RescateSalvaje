extends Node2D
## Script de cada nivel: conecta jaulas, llaves, hábitats y traficantes, y aplica las reglas.
## El número de nivel, la escena siguiente y el mensaje inicial se editan en el Inspector.

const ESCENA_ANIMAL := preload("res://Scenes/Objetos/animal.tscn")

@export var nivel : int = 1
@export_file("*.tscn") var siguiente_escena : String = ""   # vacío = último nivel
@export var musica : String = "musica"          # nombre de la música en el autoload Sonido
@export var de_noche : bool = false             # oscurece el nivel y enciende las linternas
@export_multiline var mensaje_inicio : String = "Libera a los animales del CAMPAMENTO (tecla E) y llévalos a su hábitat. ¡Que no te vean los traficantes!"

@onready var jaulas: Node2D = $Mundo/Jaulas
@onready var zonas: Node2D = $Mundo/Zonas
@onready var traficantes: Node2D = $Mundo/Traficantes
@onready var animales: Node2D = $Mundo/Animales
@onready var llaves: Node2D = get_node_or_null("Mundo/Llaves")
@onready var player: Player = $Mundo/Player
@onready var punto_inicio: Marker2D = $Mundo/PuntoInicio
@onready var hud = $HUD
@onready var ficha = $Ficha
@onready var pregunta_final = $PreguntaFinal
@onready var derrota = $Derrota


func _ready() -> void:
	GameManager.reiniciar(nivel)
	GameManager.siguiente_escena = siguiente_escena
	player.global_position = punto_inicio.global_position
	player.interactuar.connect(_on_player_interactuar)
	Sonido.tocar_musica(musica)
	player.get_node("Linterna").visible = de_noche
	if has_node("Noche"):
		get_node("Noche").visible = de_noche

	var hay_candados := false
	for jaula in jaulas.get_children():
		jaula.jugador = player
		hay_candados = hay_candados or jaula.necesita_llave
	hud.mostrar_llaves(hay_candados)
	if llaves:
		for llave in llaves.get_children():
			llave.recogida.connect(_on_llave_recogida)

	for zona in zonas.get_children():
		zona.body_entered.connect(_on_zona_body_entered.bind(zona))
	for traficante in traficantes.get_children():
		traficante.jugador = player
		traficante.atrapo_jugador.connect(_on_traficante_atrapo_jugador)
		traficante.get_node("Linterna").visible = de_noche
	hud.mostrar_mensaje(mensaje_inicio, 7.0)


func _on_player_interactuar() -> void:
	for jaula in jaulas.get_children():
		if jaula.esta_cerca(player.global_position):
			abrir_jaula(jaula)
			return


func abrir_jaula(jaula) -> void:
	if player.animal_actual != null:
		hud.mostrar_mensaje("Primero lleva a %s a su hábitat." % player.animal_actual.especie["nombre"])
		return
	if jaula.necesita_llave:
		if GameManager.llaves <= 0:
			Sonido.reproducir("error")
			hud.mostrar_mensaje("Esta jaula tiene candado. Busca una LLAVE en el mapa.")
			return
		GameManager.llaves -= 1
		jaula.necesita_llave = false
	jaula.abrir()
	Sonido.reproducir("jaula")
	var animal = ESCENA_ANIMAL.instantiate()
	animal.especie = jaula.especie
	animal.jaula = jaula
	animal.objetivo = player
	animales.add_child(animal)
	animal.global_position = jaula.global_position
	player.animal_actual = animal
	var nombre : String = jaula.especie["nombre"]
	hud.llevando = nombre
	hud.mostrar_mensaje("¡Liberaste a: %s! Llévalo a su hábitat. Si no sabes cuál es, abre la guía con G." % nombre, 5.0)


func _on_llave_recogida() -> void:
	Sonido.reproducir("llave")
	hud.mostrar_mensaje("¡Encontraste una llave! Ya puedes abrir una jaula con candado.")


func _on_zona_body_entered(cuerpo: Node2D, zona) -> void:
	if cuerpo != player or player.animal_actual == null:
		return
	var animal = player.animal_actual
	var especie : Dictionary = animal.especie

	if especie["habitat"] != zona.habitat:
		GameManager.registrar_fallo(especie["id"])
		Sonido.reproducir("error")
		hud.mostrar_mensaje("Este no es su hogar. " + especie["pista"], 5.0)
		return

	#Hábitat correcto: el animal queda libre y se desbloquea su ficha
	GameManager.registrar_rescate(especie["id"])
	Sonido.reproducir("acierto")
	player.animal_actual = null
	player.can_move = false
	hud.llevando = ""
	pausar_traficantes(true)
	await animal.liberar(animal.global_position.move_toward(zona.centro_global(), 32.0))
	pausar_traficantes(false)
	player.can_move = true
	await ficha.mostrar(especie)

	if GameManager.rescatados.size() == GameManager.total_especies():
		pregunta_final.mostrar()
	else:
		var faltan := GameManager.total_especies() - GameManager.rescatados.size()
		hud.mostrar_mensaje("¡Muy bien! Faltan %d animales por rescatar." % faltan, 3.0)


func _on_traficante_atrapo_jugador() -> void:
	if player.invulnerable:
		return
	GameManager.vidas -= 1
	player.volverse_invulnerable(2.0)
	Sonido.reproducir("dano")
	var mensaje := "¡Te atrapó un traficante!"

	#Si llevaba un animal, vuelve a su jaula
	if player.animal_actual != null:
		var animal = player.animal_actual
		mensaje += " %s volvió a su jaula." % animal.especie["nombre"]
		animal.jaula.cerrar()
		animal.queue_free()
		player.animal_actual = null
		hud.llevando = ""

	for traficante in traficantes.get_children():
		traficante.dejar_de_perseguir()

	if GameManager.vidas <= 0:
		derrota.mostrar()
		return
	player.global_position = punto_inicio.global_position
	hud.mostrar_mensaje(mensaje + " Te quedan %d corazones." % GameManager.vidas, 4.0)


func pausar_traficantes(pausar: bool) -> void:
	for traficante in traficantes.get_children():
		traficante.set_physics_process(not pausar)
