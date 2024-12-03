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
@onready var TimeDead = $TimeDead
@onready var TimerPause = $TimerPause
@onready var GladTime = $GladTime

var originaJumpDirection = 0
var originalDuckDirection = 0
var lastMoveDirection = 0
var input_direction = 0
var JUMPED_DUCK = false
var cambio = false
var paused = false
var CoinContador = 0


func _ready():
	animated_sprite.animation = "idle_right"
	animated_sprite.play()
	TimerSprite.connect("timeout", Callable(self, "gestorIdle"))  # Conecta la señal del temporizador

#	Señal recibida del script coin.gd
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.connect("coin_obteined", Callable(self, "_on_coin_obteined"))

func _on_coin_obteined():
	CoinContador = CoinContador + 1
	print(CoinContador)

func _on_player_degree():
	TimerPause.wait_time = 0.18
	TimerPause.connect("timeout", Callable(self, "pause"))
	GladTime.start()
	GladTime.connect("timeout", Callable(self, "gestionarMuerte"))  # Conecta la señal del temporizador


func _on_player_died():
	# Mario muerte
	if Global.alive2 == true:
		Global.alive2 = false
	elif Global.alive2 == false:
		Global.alive = false
		TimerPause.start()
		TimerPause.wait_time = 2
		animated_sprite.play("die")
		TimeDead.connect("timeout", Callable(self, "gestionarMuerte"))  # Conecta la señal del temporizador

func gestionarMuerte():
	if Global.alive2 == true:
		Global.alive2 = false
		TimerPause.stop()
		animated_sprite.visible = true

	elif Global.alive == false:
		if (position.y <= 600.00):
			cambio = true
			TimerPause.connect("timeout", Callable(self, "pause"))
			
		if (cambio == false):
			position.y -= 3
		elif (cambio == true && paused == true):
			position.y += 3

func _physics_process(delta):
	if not Global.alive:
		# Detener el movimiento y la gravedad
		velocity = Vector2.ZERO  # Detiene el movimiento completamente
		return
		
#	Señal recibida del script de enemy.gd
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if Global.alive2 == true:
			enemy.connect("player_down", Callable(self, "_on_player_degree"))
		elif Global.alive2 == false:
			enemy.connect("player_died", Callable(self, "_on_player_died"))
		
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
	if (Input.is_action_pressed("ui_down") and Global.alive == true): # Agachado
		velocity.x = input_direction * MOVE_DUCK_SPEED
		_activate_duck_collision()
		if (Input.is_action_pressed("ui_up") and JUMPED_DUCK == false):
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
	elif not is_on_floor() && Global.alive == true:  # En el aire
		if (input_direction >= 0 and lastMoveDirection != -1):
			animated_sprite.animation = "jump_right"
		else:
			animated_sprite.animation = "jump_left"
		animated_sprite.play()
		
	elif input_direction != 0 && Global.alive == true:
		# Movimiento horizontal
		if input_direction > 0: # Derecha
			animated_sprite.animation = "walk_right"
			lastMoveDirection = 1
		elif input_direction < 0: # Izquierda
			animated_sprite.animation = "walk_left"
			lastMoveDirection = -1
		animated_sprite.play()
		_activate_standing_collision()  # Activar colisiones de pie
		
	# Movimiento
	move_and_slide()
	
func gestorIdle():
	if (Global.alive == true and (not Input.is_action_pressed("ui_down")) and (not Input.is_action_pressed("ui_up")) and (not Input.is_action_pressed("ui_right")) and ( not Input.is_action_pressed("ui_left"))):
		#animated_sprite.animation = "idle_left" if (input_direction < 0) else "idle_right"
		if (input_direction < 0 or lastMoveDirection == -1):
			animated_sprite.animation = "idle_left"
		else:
			animated_sprite.animation = "idle_right"
		animated_sprite.play()
		
	# Reinicia el temporizador
	TimerSprite.start()

func _activate_duck_collision():
	# Desactivar las colisiones de pie
	$Mario/CollisionShape2D.set_disabled(true)
	# Activar las colisiones de agachado
	$Mario/CollisionShape2D_duck.set_disabled(false)

func _activate_standing_collision():
	# Desactivar las colisiones de agachado
	$Mario/CollisionShape2D_duck.set_disabled(true)
	# Activar las colisiones de pie
	$Mario/CollisionShape2D.set_disabled(false)
	
func pause():
	if Global.alive2 == true:
		if animated_sprite.visible == false:
			animated_sprite.visible = true
		elif animated_sprite.visible == true:
			animated_sprite.visible = false
	elif Global.alive == false:
		paused = true
		TimerPause.stop()
