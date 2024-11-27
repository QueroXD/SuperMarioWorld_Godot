extends CharacterBody2D

@export var speed: float = 100.0  # Velocidad del cohete
@export var direction: Vector2 = Vector2.LEFT  
@onready var notifier = $VisibleOnScreenNotifier2D
@onready var timer = $TimerDelete  # Asumimos que tienes un nodo Timer dentro del cohete

var on_screen: bool = false
var alive: bool = true
var delete: bool = false

# Señales
signal player_died_other

func _ready():
	# Saber si ya esta el gompa por pantalla
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	

func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible

func _on_screen_exited():
	if on_screen == false:
		queue_free()
	on_screen = false

func _on_timer_timeout():
	if delete == true:
		position.y += 3
	elif on_screen == false:
		queue_free() 

func _physics_process(delta):
	if on_screen == true && alive == true:
		move_rocket(delta)
		
func move_rocket(delta):
	if delete == false:
		position += direction * speed * delta


func _on_interaction_points_area_entered(area: Area2D) -> void:
	# Lógica para colisiones
	if area.name == "Mario":
		var player_position = area.global_position	
		if name.contains("Rocket"):
			if player_position.y >= 613 && player_position.y <= 615:
				rocket_died()
			else:
				died()
	elif area.is_in_group("Solid"): 
		queue_free()

func died():
	alive = false
	timer.stop()  # Inicia el temporizador
	emit_signal("player_died_other")  # Envía la señal al jugador

func rocket_died():
	timer.start(0.05)
	delete = true
	$InteractionPoints.queue_free
	$InteractionPoints/CollisionShape2D.queue_free
	$CollisionShape2D.queue_free()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
