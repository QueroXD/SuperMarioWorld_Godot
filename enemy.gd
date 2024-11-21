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
	
	#Colision Mario + Enemigo
	collision.connect("body_entered", Callable(self, "_on_body_entered"))
	
	
	
func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible
	timer.start()  # Inicia el temporizador

func _on_screen_exited():
	on_screen = false  # Marca al Gompa como no visible
	timer.stop()  # Inicia el temporizador

func _on_body_entered(body):
	if body.name == "Player":  # Cambia "Player" por el nombre exacto del nodo de Mario
		print(position.x)
		print(body.position.x)
		if is_colliding_with_top(body):
			queue_free() # Eliminar Gomba

# Función para verificar si Mario colide con la parte superior del Gompa
func is_colliding_with_top(body):
	## Obtener la posición y el tamaño del CollisionShape2D del Gompa
	#var collision_shape = $CollisionShape2D
	#if not collision_shape or not collision_shape.shape:
		#return false  # Si no hay una forma válida, no hay colisión
#
	#var gompa_top = position.y - collision_shape.shape.extents.y  # Línea superior del Gompa
	#var gompa_left = position.x - collision_shape.shape.extents.x  # Borde izquierdo
	#var gompa_right = position.x + collision_shape.shape.extents.x  # Borde derecho
#
	## Obtener la posición de Mario (body)
	#var mario_bottom = body.position.y + body.get_node("CollisionShape2D").shape.extents.y
	#var mario_center_x = body.position.x  # Punto central en X de Mario
#
	## Verificar si Mario toca la "línea superior" del Gompa
	#if mario_bottom >= gompa_top and mario_bottom <= gompa_top + 5:  # Línea superior con un margen
		#if mario_center_x >= gompa_left and mario_center_x <= gompa_right:  # Dentro del rango horizontal
			#return true
	#return false
	var mario_bottom = body.position.y
	var collision_shape = $CollisionShape2D

	if (body.position.y+collision_shape.shape.extents.y) >= position.y or (body.position.y-collision_shape.shape.extents.y) >= position.y:
		return true
	return false

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
