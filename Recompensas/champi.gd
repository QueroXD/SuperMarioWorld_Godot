extends CharacterBody2D

# Variables de control
@export var gravity: float = 500.0
@export var speed: float = 25.0
var input_direction: Vector2 = Vector2.RIGHT 

func _ready():
	velocity = input_direction * speed

func _physics_process(delta):
	# Aplicar gravedad
	velocity.y += gravity * delta

	# Mover el champiñón
	move_and_slide()

	# Verificar colisiones
	if is_on_wall():
		if input_direction == Vector2.RIGHT:
			input_direction = Vector2.LEFT
		else:
			input_direction = Vector2.RIGHT

	if is_on_floor():
		velocity = input_direction * speed
		velocity.y = 0  # Detener la velocidad vertical al tocar el suelo

func _on_interaction_points_area_entered(area: Area2D) -> void:
		if area.name == "Mario":
			if name.contains("Champi"):
				Global.alive2 = true
				queue_free()
