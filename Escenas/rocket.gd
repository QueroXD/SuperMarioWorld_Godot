extends Area2D

@export var speed: float = 35.0  # Velocidad del cohete
@export var direction: Vector2 = Vector2.LEFT  
@onready var timer = $TimerDelete  # Asumimos que tienes un nodo Timer dentro del cohete

func _ready():
	timer.start(3.0)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	queue_free() 

func _physics_process(delta):
	move_rocket(delta)

func _on_area_entered(area):
	# Lógica para colisiones
	if area.name == "Mario":
		if name.contains("rocket"):
			queue_free()  # Destruye el cohete
	elif area.is_in_group("Solid"): 
		queue_free()
		
		
func move_rocket(delta):
	position += direction * speed * delta
