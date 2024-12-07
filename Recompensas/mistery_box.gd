extends StaticBody2D

@onready var champi_scene: PackedScene = preload("res://Recompensas/Champi.tscn")
@onready var animation_sprite = $AnimatedSprite2D


func _ready():
	animation_sprite.play("default")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Mario":
		print(name)
		if name.contains("MisteryBox"):
			if animation_sprite.animation != "NoReward":
				InvokeReward()
			animation_sprite.play("NoReward")

func InvokeReward():
	# Crear un nuevo cohete
	var champi = champi_scene.instantiate()
	get_tree().root.add_child(champi)
	
# Posicionar el champi justo encima
	champi.global_position.x = global_position.x
	champi.global_position.y = global_position.y - 18
