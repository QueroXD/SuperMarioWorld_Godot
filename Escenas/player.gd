extends CharacterBody2D

# Constantes
const GRAVITY = 1200.0
const MOVE_SPEED = 200.0
const JUMP_FORCE = -500.0
const MAX_FALL_SPEED = 900.0

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Movimiento horizontal
	var input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_direction * MOVE_SPEED

	# Salto
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	# Límite de velocidad de caída
	velocity.y = clamp(velocity.y, -INF, MAX_FALL_SPEED)

	# Movimiento
	move_and_slide()
