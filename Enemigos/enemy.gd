extends Node2D

# Variables para movimiento y comportamiento
@export var speed: float = 25.0
@export var direction: Vector2 = Vector2.LEFT
var on_screen: bool = false
var standit: bool = false
var move: bool = false
var alive: bool = true
var petit: bool = false
var petitx2: bool = false

# Referencias a nodos hijos
@onready var animated_sprite = $AnimatedSprite2D
@onready var notifier = $VisibleOnScreenNotifier2D
@onready var collision = $InteractionPoints
@onready var timer = $Timer

# Señales
signal player_died


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
	if on_screen && (standit == false || move == true) && alive == true:
		move_enemy(delta)

func move_enemy(delta):
	# Mueve al Gompa
	position += direction * speed * delta
	
func _on_timer_timeout():
	if (standit == false):
		# Cambia la dirección y animación cada 4 segundos
		if direction == Vector2.LEFT:
			direction = Vector2.RIGHT
			if petit == true:
				$InteractionPoints/CollisionShape2D_Mini.set_process(true) 
				$CollisionShape2D_Mini.set_process(true) 
				animated_sprite.play("run_mini_right")
				petitx2 = false
			else:
				animated_sprite.play("run_right")
		else:
			direction = Vector2.LEFT
			if petit == true:
				$InteractionPoints/CollisionShape2D_Mini.set_process(true) 
				$CollisionShape2D_Mini.set_process(true) 
				animated_sprite.play("run_mini_left")
				petitx2 = false
			else:
				animated_sprite.play("run_left")

		# Reinicia el temporizador
		timer.start()

func _on_interaction_points_area_entered(area: Area2D) -> void:
	if (area.name == "Mario"&& alive == true ):
		var player_position = area.global_position	
		if name.contains("Koopa"):  # Basado en el nombre del nodo
			if player_position.y > 587 && player_position.y < 589:
				if standit == false:
					animated_sprite.play("stand")
					timer.stop()  # Inicia el temporizador
					standit = true;
				else:
					queue_free()  # Elimina al enemigo
			else:
				if standit == true:
					move = true
					if (Input.get_action_strength("ui_right")):
						direction = Vector2.RIGHT
					elif (Input.get_action_strength("ui_left")):
						direction = Vector2.LEFT
					speed = 75.00
				else:
					died()
					print("Jugador muerto")
		elif name.contains("Gomba"):  # Basado en el nombre del nodo
			# Comprueba si el jugador está cayendo desde arriba
			if player_position.y > 661 && player_position.y < 663:
				queue_free()  # Elimina al enemigo
			else:
				died()
				print("Jugador muerto")
		elif name.contains("Ankylosaurus"):
			print(player_position.y)
			print(petitx2)
			if player_position.y > 646 && player_position.y < 648:
				petit = true
				$InteractionPoints/CollisionShape2D_Mayor.queue_free()
				$CollisionShape2D_Mayor.queue_free()
				if direction == Vector2.RIGHT:
					animated_sprite.play("run_mini_right")
				else:
					animated_sprite.play("run_mini_left")
			elif petitx2 == false && petit == true && player_position.y > 663 && player_position.y < 665:
				$InteractionPoints/CollisionShape2D_Mini.set_process(false) 
				$CollisionShape2D_Mini.set_process(false) 
				petitx2 = true
				if direction == Vector2.RIGHT:
					animated_sprite.play("enemy_dead_right")
				else:
					animated_sprite.play("enemy_dead_left")
			elif (petitx2 == true && ((player_position.y > 668 && player_position.y < 670) or (player_position.y > 663 && player_position.y < 665))):
				$InteractionPoints/CollisionShape2D_Mini.queue_free()
				$CollisionShape2D_Mini.queue_free()
				queue_free()
			else:
				died()
				print("Jugador muerto")

func died():
	alive = false
	animated_sprite.stop()
	timer.stop()  # Inicia el temporizador
	emit_signal("player_died")  # Envía la señal al jugador
