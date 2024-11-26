extends Camera2D

# Constantes para los límites de la cámara
@export var level_limits: Rect2 = Rect2(Vector2(0, 0), Vector2(3000, 1080)) # Ajusta al tamaño del nivel.
@export var follow_speed: float = 5.0 # Suavidad del seguimiento.

func _ready() -> void:
	if get_parent():
		# Posiciona la cámara directamente sobre el jugador al inicio
		global_position = get_parent().global_position
		# Restringe dentro de los límites al iniciar
		global_position = global_position.clamp(level_limits.position, level_limits.position + level_limits.size)

func _process(delta: float) -> void:
	if get_parent():
		# Sigue al jugador suavemente usando lerp
		global_position = global_position.lerp(get_parent().global_position, follow_speed * delta)
		
		# Restringe la cámara dentro de los límites del nivel
		global_position = global_position.clamp(level_limits.position, level_limits.position + level_limits.size)
