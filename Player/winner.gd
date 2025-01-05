extends Control

@onready var winnerSound = $winnerSound
@onready var numTime = $CanvasLayer/Background/numTime
@onready var resultMultiplier = $CanvasLayer/Background/resultMultiplier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	winnerSound.play(0.0)
	numTime.text = str(Global.timeValue)
	resultMultiplier.text = str(Global.timeValue*50)
		
	$AnimationPlayer.play("Winner")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
