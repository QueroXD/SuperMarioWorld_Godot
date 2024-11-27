extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

# Señales
signal coin_obteined

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("default")
	pass # Replace with function body.

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.name == "Mario"):
		emit_signal("coin_obteined")  # Envía la señal al jugador
		queue_free()
