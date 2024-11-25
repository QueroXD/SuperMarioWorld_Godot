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
@onready var TimerSprite = $TimerSprite
var originaJumpDirection = 0
var originalDuckDirection = 0
var lastMoveDirection = 0
var input_direction = 0
var JUMPED_DUCK = false


func _ready():
	animated_sprite.animation = "idle_right"
	animated_sprite.play()
	TimerSprite.connect("timeout", Callable(self, "gestorIdle"))  # Conecta la señal del temporizador

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		originaJumpDirection = 0
		JUMPED_DUCK = false

	# Movimiento horizontal
	input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_direction * MOVE_SPEED

	# Salto
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = JUMP_FORCE

	# Límite de velocidad de caída
	velocity.y = clamp(velocity.y, -INF, MAX_FALL_SPEED)

	 #Animaciones
	if (Input.is_action_pressed("ui_down")): # Agachado
		velocity.x = input_direction * MOVE_DUCK_SPEED
		if (Input.is_action_pressed("ui_up") and JUMPED_DUCK == false):
			#animated_sprite.animation = "duck_right" if (input_direction > 0) else "duck_left"
			velocity.y = JUMP_DUCK
			if (input_direction > 0):
				animated_sprite.animation = "duck_right"
				originalDuckDirection = 1
			elif (input_direction < 0):
				animated_sprite.animation = "duck_left"
				originalDuckDirection = -1
			JUMPED_DUCK = true
			animated_sprite.play()
		else:
			if ((input_direction >= 0) and (lastMoveDirection != -1)):
				animated_sprite.animation = "duck_right"
			else:
				animated_sprite.animation = "duck_left"
			animated_sprite.play()
	elif not is_on_floor():  # En el aire
		if (input_direction >= 0 and lastMoveDirection != -1):
			animated_sprite.animation = "jump_right"
		else:
			animated_sprite.animation = "jump_left"
		animated_sprite.play()
	elif input_direction != 0:
		# Movimiento horizontal
		if input_direction > 0: # Derecha
			animated_sprite.animation = "walk_right"
			lastMoveDirection = 1
		elif input_direction < 0: # Izquierda
			animated_sprite.animation = "walk_left"
			lastMoveDirection = -1
		animated_sprite.play()
	# Movimiento
	move_and_slide()
	
func gestorIdle():
	if ((not Input.is_action_pressed("ui_down")) and (not Input.is_action_pressed("ui_up")) and (not Input.is_action_pressed("ui_right")) and ( not Input.is_action_pressed("ui_left"))):
		#animated_sprite.animation = "idle_left" if (input_direction < 0) else "idle_right"
		if (input_direction < 0 or lastMoveDirection == -1):
			animated_sprite.animation = "idle_left"
		else:
			animated_sprite.animation = "idle_right"
		animated_sprite.play()
		
	# Reinicia el temporizador
	TimerSprite.start()
