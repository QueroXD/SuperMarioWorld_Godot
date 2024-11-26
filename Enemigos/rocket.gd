extends CharacterBody2D

@export var speed: float = 100.0  # Velocidad del cohete
@export var direction: Vector2 = Vector2.LEFT  
@onready var notifier = $VisibleOnScreenNotifier2D
@onready var timer = $TimerDelete  # Asumimos que tienes un nodo Timer dentro del cohete

var on_screen: bool = false
var alive: bool = true

# Señales
signal player_died

func _ready():
	# Saber si ya esta el gompa por pantalla
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))
	

func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible

func _on_screen_exited():
	if on_screen == true:
		timer.start(3.0)
		timer.connect("timeout", Callable(self, "_on_timer_timeout"))
		timer.start()  # Inicia el temporizador
	on_screen = false

func _on_timer_timeout():
	queue_free() 

func _physics_process(delta):
	if on_screen == true && alive == true:
		move_rocket(delta)
		
func move_rocket(delta):
	position += direction * speed * delta


func _on_interaction_points_area_entered(area: Area2D) -> void:
	# Lógica para colisiones
	if area.name == "Mario":
		if name.contains("Rocket"):
			died()
	elif area.is_in_group("Solid"): 
		queue_free()

func died():
	alive = false
	timer.stop()  # Inicia el temporizador
	emit_signal("player_died")  # Envía la señal al jugador
