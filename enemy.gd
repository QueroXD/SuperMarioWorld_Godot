extends Node2D

# Variables para movimiento y comportamiento
@export var speed: float = 25.0
@export var direction: Vector2 = Vector2.LEFT
var on_screen: bool = false

# Referencias a nodos hijos
@onready var animated_sprite = $AnimatedSprite2D
@onready var notifier = $VisibleOnScreenNotifier2D
@onready var collision = $InteractionPoints
@onready var timer = $Timer


func _ready():
	# Inicia animaciones y temporizadores si es necesario
	animated_sprite.play("run_left")  # Cambia "walk" por el nombre de tu animación
	timer.wait_time = 5.0  # Duración del temporizador (4 segundos)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))  # Conecta la señal del temporizador
	
	# Saber si ya esta el gompa por pantalla
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	
func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible
	timer.start()  # Inicia el temporizador

func _on_screen_exited():
	on_screen = false  # Marca al Gompa como no visible
	timer.stop()  # Inicia el temporizador

func _physics_process(delta):
	if on_screen:
		move_enemy(delta)

func move_enemy(delta):
	# Mueve al Gompa
	position += direction * speed * delta
	
func _on_timer_timeout():
	# Cambia la dirección y animación cada 4 segundos
	if direction == Vector2.LEFT:
		direction = Vector2.RIGHT
		animated_sprite.play("run_right")
	else:
		direction = Vector2.LEFT
		animated_sprite.play("run_left")

	# Reinicia el temporizador
	timer.start()

func _on_interaction_points_area_entered(area: Area2D) -> void:
	if (area.name == "Mario"):
		var player_position = area.global_position	
		if name.contains("Koopa"):  # Basado en el nombre del nodo
			print(player_position.y)
			print(position.y)
			if player_position.y > 587 && player_position.y < 589:
				print("El jugador viene desde arriba")
				queue_free()  # Elimina al enemigo
			else:
				print("El jugador no viene desde arriba")
		elif name.contains("Gomba"):  # Basado en el nombre del nodo
			# Comprueba si el jugador está cayendo desde arriba
			if player_position.y > 661 && player_position.y < 663:
				print("El jugador viene desde arriba")
				queue_free()  # Elimina al enemigo
			else:
				print("El jugador no viene desde arriba")
