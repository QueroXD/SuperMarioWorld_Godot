extends CharacterBody2D

const MOVE_SPEED = 50.0
const GRAVITY = 1200.0
const MAX_FALL_SPEED = 900.0

var alive: bool = true
var cambio: bool = false

# Señales
signal player_died_other

func _physics_process(delta: float) -> void:
	if is_on_floor() && alive == true:  # Verificar si está sobre el suelo
		var normal = get_floor_normal()  # Obtener la normal de la superficie en la que está el koopa_otaku
		if cambio == false:  # Si 'cambio' es falso, se sigue la pendiente
			velocity.x = normal.x * MOVE_SPEED  # Ajustar la velocidad horizontal según la pendiente
			velocity.y = normal.y * MOVE_SPEED  # Ajustar la velocidad vertical según la pendiente
		else:
			# Si ya ha caído y 'cambio' es verdadero, solo mueve hacia la izquierda
			velocity.x = -MOVE_SPEED  # Mover hacia la izquierda a velocidad constante
			velocity.y = 0  # Evitar "saltos" adicionales al caer
	elif alive == true:
		cambio = true
		# Si no está en una superficie, aplicar gravedad
		velocity += Vector2(0, GRAVITY) * delta
	
	if position.x <= -25:
		queue_free()
	
	# Límite de velocidad de caída
	velocity.y = clamp(velocity.y, -INF, MAX_FALL_SPEED)
	
	# Llamada a move_and_slide() sin argumentos
	move_and_slide()


func _on_interaction_points_area_entered(area: Area2D) -> void:		
	if (area.name == "Mario"&& alive == true ):
		var player_position = area.global_position	
		print(player_position.y)
		if player_position.y > 662 && player_position.y < 664:
			queue_free()
		else:
			died()
			
func died():
	alive = false
	#animated_sprite.stop()
	emit_signal("player_died_other")  # Envía la señal al jugador
