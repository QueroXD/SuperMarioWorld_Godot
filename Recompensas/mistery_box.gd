extends StaticBody2D

@onready var champi_scene: PackedScene = preload("res://Recompensas/Champi.tscn")

@onready var animation_sprite = $AnimatedSprite2D
@onready var notifier = $VisibleOnScreenNotifier2D

var on_screen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_sprite.play("default")
	on_screen = false

func _physics_process(delta):
	if on_screen == true:
		pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Mario":
		if name.contains("MysteriBox"):
			if animation_sprite.animation != "NoReward":
				InvokeReward()
			animation_sprite.play("NoReward")
			

func InvokeReward():
	# Crear un nuevo cohete
	var champi = champi_scene.instantiate()
	get_tree().root.add_child(champi)  # Agregar el cohete a la escena principal (o donde corresponda)
	
# Posicionar el champi justo encima
	champi.global_position.x = global_position.x
	champi.global_position.y = global_position.y - 18
