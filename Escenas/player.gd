extends CharacterBody2D

# Constantes
const GRAVITY = 1200.0
const JUMP_DUCK = -250.0
const MOVE_SPEED = 200.0
const MOVE_DUCK_SPEED = 50.0
const JUMP_FORCE = -500.0
const MAX_FALL_SPEED = 900.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

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
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_FORCE

	# Límite de velocidad de caída
	velocity.y = clamp(velocity.y, -INF, MAX_FALL_SPEED)

	# Animaciones
	if (Input.is_action_pressed("ui_down")): # Agachado
		velocity.x = input_direction * MOVE_DUCK_SPEED
		if not is_on_floor(): velocity.y = JUMP_DUCK
		animated_sprite.animation = "duck_right" if (input_direction > 0) else "duck_left"
		animated_sprite.play()
	elif not is_on_floor():  # En el aire
		animated_sprite.animation = "jump_right" if (input_direction > 0) else "jump_left"
		animated_sprite.play()
	elif input_direction != 0:
		# Movimiento horizontal
		if input_direction > 0: # Derecha
			animated_sprite.animation = "walk_right"
			animated_sprite.flip_h = false
		elif input_direction < 0: # Izquierda
			animated_sprite.animation = "walk_left"
			animated_sprite.flip_h = false # Para hacer un espejo del sprite escojido    
		animated_sprite.play()
	else:
		# Estaido inactivo
		animated_sprite.animation = "idle_left" if (input_direction > 0) else "idle_right"
		animated_sprite.play()

	# Movimiento
	move_and_slide()
