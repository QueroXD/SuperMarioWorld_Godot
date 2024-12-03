extends CharacterBody2D


const SPEED = 25.0
const AMPLITUDE = 35.0
const FREQUENCY = 2.5 

@onready var champi_scene: PackedScene = preload("res://Recompensas/Champi.tscn")

@onready var animation_sprite = $AnimatedSprite2D
@onready var notifier = $VisibleOnScreenNotifier2D

var on_screen = false
var enteredDetec = false
var input_direction: Vector2 = Vector2.LEFT
var time_elapsed: float = 0.0

func _ready():
	animation_sprite.play("default")
	# Saber si ya esta el gompa por pantalla
	notifier.connect("screen_entered", Callable(self, "_on_screen_entered"))
	notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _on_screen_entered():
	on_screen = true  # Marca al Gompa como visible

func _on_screen_exited():
	on_screen = false  # Marca al Gompa como no visible

func _physics_process(delta: float) -> void:
	if on_screen == true && enteredDetec == false:
		# Movimiento horizontal constante basado en la dirección especificada
		velocity.x = input_direction.x * SPEED

		# Movimiento vertical sinusoidal
		time_elapsed += delta
		velocity.y = AMPLITUDE * sin(FREQUENCY * time_elapsed)

		# Aplicar el movimiento
		move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Mario":
		print(name)
		if name.contains("MisteryBoxAngel"):
			if animation_sprite.animation != "NoReward":
				InvokeReward()
			animation_sprite.play("NoReward")
			
func InvokeReward():
	enteredDetec = true
	# Crear un nuevo cohete
	var champi = champi_scene.instantiate()
	get_tree().root.add_child(champi)  # Agregar el cohete a la escena principal (o donde corresponda)
	
# Posicionar el champi justo encima
	champi.global_position.x = global_position.x
	champi.global_position.y = global_position.y - 18
