extends Node2D

@export var fire_rate: float = 5  # Tiempo entre disparos en segundos
@onready var rocket_scene: PackedScene = preload("res://Enemigos/rocket.tscn")

#@onready var launch_point = $LaunchPoint
@onready var fire_timer = $FireTimer
@onready var notifier = $VisibleOnScreenNotifier2D

var on_screen: bool = false

func _ready():
	# Configura el temporizador
	fire_timer.connect("timeout", Callable(self._fire_rocket))
	
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	
func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible
	fire_timer.start()  # Inicia el temporizador
	fire_timer.wait_time = fire_rate

func _on_screen_exited():
	on_screen = false  # Marca al Gompa como no visible
	fire_timer.stop()  # Inicia el temporizador

func _fire_rocket():
	# Crear un nuevo cohete
	var rocket = rocket_scene.instantiate()
	get_tree().root.add_child(rocket)  # Agregar el cohete a la escena principal (o donde corresponda)

	# Posicionar el cohete justo encima del lanzador
	rocket.global_position.x = global_position.x
	rocket.global_position.y = global_position.y - 9
	rocket.direction = Vector2.LEFT  # Configurar dirección inicial (hacia arriba)
	
