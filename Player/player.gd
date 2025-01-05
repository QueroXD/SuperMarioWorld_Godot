extends CharacterBody2D

# Constantes
const GRAVITY = 1200.0
const JUMP_DUCK = -250.0
const MOVE_SPEED = 200.0
const MOVE_DUCK_SPEED = 50.0
const JUMP_FORCE = -500.0
const MAX_FALL_SPEED = 900.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_sprite2 = $AnimatedSprite2D_UP
@onready var collision = $CollisionShape2D
@onready var TimerSprite = $TimerSprite
@onready var TimeDead = $TimeDead
@onready var TimerPause = $TimerPause
@onready var GladTime = $GladTime

@onready var overworldMusic = $OverWorld
@onready var undergroundMusic = $Underground
@onready var jumpSound = $Jump
@onready var mushroomSound = $Champi
@onready var pipeDamageSound = $PipeDamage

var subnivel = load("res://Niveles/lvl__1_1b.tscn")
#var subnivel_path = "res://Niveles/lvl__1_1b.tscn"
#var nivelAlpha = preload("res://Niveles/lvl__1_1a.tscn")


var originaJumpDirection = 0
var originalDuckDirection = 0
var lastMoveDirection = 0
var input_direction = 0
var JUMPED_DUCK = false
var cambio = false
var paused = false
var CambioScena = false


func _ready():
	overworldMusic.play(0.0)
	
	animated_sprite.play("idle_right")
	TimerSprite.connect("timeout", Callable(self, "gestorIdle"))  # Conecta la señal del temporizador
	
	# Desactivar UP
	$Mario/CollisionShape2D_UP.set_disabled(true)
	$CollisionShape2D_UP.set_disabled(true)
	$AnimatedSprite2D_UP.visible = false

#	Señal recibida del script coin.gd
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.connect("coin_obteined", Callable(self, "_on_coin_obteined"))
	
	for dragonCoin in get_tree().get_nodes_in_group("dragonCoin"):
		dragonCoin.connect("dragonCoin_obteined", Callable(self, "_on_dragonCoin_obteined"))

func _on_coin_obteined():
	Global.coins += 1

func _on_dragonCoin_obteined():
	Global.dragonCoins += 1
	Global.coins += 1
	Global.points += 1000

func _on_player_degree():
	pipeDamageSound.play(0.0)	
	TimerPause.wait_time = 0.18
	TimerPause.connect("timeout", Callable(self, "pause"))
	GladTime.start()
	GladTime.connect("timeout", Callable(self, "gestionarMuerte"))  # Conecta la señal del temporizador

func _on_player_died():
	overworldMusic.stop()	
	# Mario muerte
	if Global.alive2 == true:
		Global.alive2 = false
	elif Global.alive2 == false:
		Global.alive = false
		TimerPause.start()
		TimerPause.wait_time = 2
		animated_sprite.play("die")
		TimeDead.connect("timeout", Callable(self, "gestionarMuerte"))  # Conecta la señal del temporizador
		load_game_over_scene()

func gestionarMuerte():
	if Global.alive2 == true:
		Global.alive2 = false
		TimerPause.stop()
		animated_sprite2.visible = false
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
	if position.y >= 750 and not Global.tuberia:
		Global.alive2 = false  # Usa '=' en lugar de '=='
		_on_player_died()

	if not Global.alive:
		# Detener el movimiento y la gravedad
		velocity = Vector2.ZERO  # Detiene el movimiento completamente
		return
		
	if Global.alive2:
		_toggle_mushroom_state(true)  # Activar estado del hongo
	else:
		_toggle_mushroom_state(false)  # Desactivar estado del hongo
	
	#Señal recibida del script de enemy.gd
	for enemy in get_tree().get_nodes_in_group("enemy"):
		# Verifica si la señal está conectada antes de intentar desconectarla
		if enemy.is_connected("player_down", Callable(self, "_on_player_degree")):
			enemy.disconnect("player_down", Callable(self, "_on_player_degree"))
		
		if enemy.is_connected("player_died", Callable(self, "_on_player_died")):
			enemy.disconnect("player_died", Callable(self, "_on_player_died"))
		
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
		jumpSound.play(0.0)
		velocity.y = JUMP_FORCE

	# Límite de velocidad de caída
	velocity.y = clamp(velocity.y, -INF, MAX_FALL_SPEED)

	 #Animaciones
	if (Input.is_action_pressed("ui_down") and Global.alive == true): # Agachado
		velocity.x = input_direction * MOVE_DUCK_SPEED
		_activate_duck_collision()
		print(position.x)
		print(position.y)
		if (Input.is_action_pressed("ui_up") and JUMPED_DUCK == false):
			jumpSound.play(0.0)
			velocity.y = JUMP_DUCK
			if (input_direction > 0):
				if Global.alive2 == true:
					animated_sprite2.play("duck_right_up")
				else:
					animated_sprite.play("duck_right")
				originalDuckDirection = 1
			elif (input_direction < 0):
				if Global.alive2 == true:
					animated_sprite2.play("duck_left_up")
				else:
					animated_sprite.play("duck_left")
				originalDuckDirection = -1
			JUMPED_DUCK = true
		else:
			if ((input_direction >= 0) and (lastMoveDirection != -1)):
				if Global.alive2 == true:
					animated_sprite2.play("duck_right_up")
				else:
					animated_sprite.play("duck_right")
			else:
				if Global.alive2 == true:
					animated_sprite2.play("duck_left_up")
				else:
					animated_sprite.play("duck_left")

	elif not is_on_floor() && Global.alive == true:  # En el aire
		if (input_direction >= 0 and lastMoveDirection != -1):
			if Global.alive2 == true:
				animated_sprite2.play("jump_right_up")
			else:
				animated_sprite.play("jump_right")
		else:
			if Global.alive2 == true:
				animated_sprite2.play("jump_left_up")
			else:
				animated_sprite.play("jump_left")
		
	elif input_direction != 0 && Global.alive == true:
		# Movimiento horizontal
		if input_direction > 0: # Derecha
			if Global.alive2 == true:
				animated_sprite2.play("walk_right_up")
			else:
				animated_sprite.play("walk_right")
			lastMoveDirection = 1
		elif input_direction < 0: # Izquierda
			if Global.alive2 == true:
				animated_sprite2.play("walk_left_up")
			else:
				animated_sprite.play("walk_left")
			lastMoveDirection = -1
		_activate_standing_collision()  # Activar colisiones de pie
		
	if (position.x > 2434 && position.x < 2461 && (Input.is_action_pressed("ui_down") and Global.alive == true) && position.y <= 647 && position.y > 644 ):
		pipeDamageSound.play(0.0)
		overworldMusic.stop()
		undergroundMusic.play(0.0)
		Global.tuberia = true
		position.x = 2450
		position.y = 910
		
	if (position.x > 2981 && Global.tuberia == true && Global.alive == true && Input.is_action_pressed("ui_right") && position.y > 938 && position.y < 940):
		pipeDamageSound.play(0.0)
		undergroundMusic.stop()
		overworldMusic.play(0.0)
		Global.tuberia = false
		position.x = 2615
		position.y = 600
		
	if (position.x > 6239 && Global.alive == true):
		TimerPause.start()
		TimerPause.wait_time = 2
		print("Winner")
		Global.winner = true
		load_winner_scene()
		
	# Movimiento
	move_and_slide()

func gestorIdle():
	if (Global.alive == true and (not Input.is_action_pressed("ui_down")) and (not Input.is_action_pressed("ui_up")) and (not Input.is_action_pressed("ui_right")) and ( not Input.is_action_pressed("ui_left"))):
		if (input_direction < 0 or lastMoveDirection == -1):
			if Global.alive2 == true:
				animated_sprite2.play("idle_left_up")
			else:
				animated_sprite.play("idle_left")
		else:
			if Global.alive2 == true:
				animated_sprite2.play("idle_right_up")
			else:
				animated_sprite.play("idle_right")
	# Reinicia el temporizador
	TimerSprite.start()

func _activate_duck_collision():
	if Global.alive2:
		# Desactivar las colisiones de pie
		$Mario/CollisionShape2D_UP.set_disabled(true)
	else:
		$Mario/CollisionShape2D.set_disabled(true)

	# Activar las colisiones de agachado
	$Mario/CollisionShape2D_duck.set_disabled(false)

func _activate_standing_collision():
	# Desactivar las colisiones de agachado
	$Mario/CollisionShape2D_duck.set_disabled(true)
	if Global.alive2 == true:
		# Activar las colisiones de pie
		$Mario/CollisionShape2D_UP.set_disabled(false)
	else:
		# Activar las colisiones de pie
		$Mario/CollisionShape2D.set_disabled(false)
	
func pause():
	if Global.alive2 == true:
		if animated_sprite2.visible == false:
			animated_sprite2.visible = true
		elif animated_sprite2.visible == true:
			animated_sprite2.visible = false
	elif Global.alive == false:
		paused = true
		TimerPause.stop()

func load_game_over_scene():
	overworldMusic.stop()  # Detener la música del mundo exterior cuando se gana.

	# Pausar el árbol globalmente
	get_tree().paused = true

	# Instanciar la escena de ganador
	var scene_resource = load("res://Player/game_over.tscn")
	var game_over = scene_resource.instantiate()
	get_tree().root.add_child(game_over)  # Agregar la escena al árbol de nodos.

	# Despausar solo la escena winner, estableciendo su Process Mode en "Always"
	game_over.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	game_over.set_physics_process(true)  # Si es necesario, habilitar también la física.

	# Asegúrate de que si hay un nodo de audio, no esté detenido
	var audio_player = game_over.get_node_or_null("AudioStreamPlayer")
	if audio_player:
		audio_player.play()  # Reproducir el audio asociado a la escena de ganador	

func load_winner_scene():
	overworldMusic.stop()  # Detener la música del mundo exterior cuando se gana.

	# Pausar el árbol globalmente
	get_tree().paused = true

	# Instanciar la escena de ganador
	var scene_resource = load("res://Player/winner.tscn")
	var winner_scene = scene_resource.instantiate()
	get_tree().root.add_child(winner_scene)  # Agregar la escena al árbol de nodos.

	# Despausar solo la escena winner, estableciendo su Process Mode en "Always"
	winner_scene.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	winner_scene.set_physics_process(true)  # Si es necesario, habilitar también la física.

	# Asegúrate de que si hay un nodo de audio, no esté detenido
	var audio_player = winner_scene.get_node_or_null("AudioStreamPlayer")
	if audio_player:
		audio_player.play()  # Reproducir el audio asociado a la escena de ganador	

var isMushroomSoundPlaying = false  # Variable para verificar si el audio está en reproducción

func _toggle_mushroom_state(enable: bool):
	if enable and not isMushroomSoundPlaying:
		isMushroomSoundPlaying = true  # Marcar que el sonido está en reproducción

		# Conectar la señal solo si no está conectada
		if not mushroomSound.is_connected("finished", Callable(self, "_on_mushroom_sound_finished")):
			mushroomSound.connect("finished", Callable(self, "_on_mushroom_sound_finished"))  # Conectar la señal
		
		mushroomSound.stop()
		mushroomSound.play(0.0)  # Reproducir solo la primera vez
		
		# Activar
		$Mario/CollisionShape2D_UP.set_disabled(false)
		$CollisionShape2D_UP.set_disabled(false)
		$AnimatedSprite2D_UP.visible = true
		
		# Desactivar
		$Mario/CollisionShape2D.set_disabled(true)
		$CollisionShape2D.set_disabled(true)
		$AnimatedSprite2D.visible = false
	elif not enable:
		mushroomSound.stop()
		isMushroomSoundPlaying = false  # Restablecer la variable cuando el sonido se detiene

func _on_mushroom_sound_finished():
	mushroomSound.stop()
	mushroomSound.disconnect("finished", Callable(self, "_on_mushroom_sound_finished"))
