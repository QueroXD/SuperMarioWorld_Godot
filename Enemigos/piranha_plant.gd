extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var notifier = $VisibleOnScreenNotifier2D
@onready var timeChange = $Timer
@onready var animation_sprite = $AnimatedSprite2D

var on_screen = false
var cambio = false

signal player_died_other

func _ready():
	animation_sprite.play("default")
	
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible

func _on_screen_exited():
	if on_screen == true:
		queue_free()

func _physics_process(delta):
	if on_screen == true && Global.alive == true:
		timeChange.connect("timeout", Callable(self, "vuelta"))		


func _on_interaction_points_area_entered(area: Area2D) -> void:
	if area.name == "Mario":
		if name.contains("Plant"):
			died()
	
func died():
	if Global.alive2 == false:
		timeChange.queue_free()  # Inicia el temporizador
		animation_sprite.stop()
		emit_signal("player_died_other")  # Envía la señal al jugador
	else:
		emit_signal("player_died_other")  # Envía la señal al jugador

func vuelta():
	if cambio == false && Global.alive == true:
		if position.y <= 550:
			cambio = true
		elif position.y >= 550:
			position.y -= 10
	elif cambio == true && Global.alive == true:
		timeChange.wait_time = 0.4
		if position.y <= 615:
			position.y += 4
		elif position.y > 615:
			queue_free()
