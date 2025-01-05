extends Control

var timer_value: int = 300

@onready var timeUI = $CanvasLayer/time/timeNum 
@onready var timer = $CanvasLayer/CountdownTimer
@onready var coins = $CanvasLayer/numMonedas
@onready var points = $CanvasLayer/numPuntos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeUI.text = str(Global.timeValue)
	if !Global.winner:
		timer.connect("timeout",Callable(self, "_on_timer_timeout"))
		timer.start()
		$CanvasLayer/monedaEstrella1.hide()
		$CanvasLayer/monedaEstrella2.hide()
		$CanvasLayer/monedaEstrella3.hide()
		$CanvasLayer/monedaEstrella4.hide()

func _on_timer_timeout():
	if !Global.winner:
		Global.timeValue -= 1
		
	timeUI.text = str(Global.timeValue)
	coins.text = str(Global.coins)
	points.text = str(Global.points).pad_zeros(4)
		
	if Global.timeValue <= 0:
		timer.stop()
	
	if Global.dragonCoins == 1:
		$CanvasLayer/monedaEstrella1.show()
	elif Global.dragonCoins == 2:
		$CanvasLayer/monedaEstrella2.show()
	elif Global.dragonCoins == 3:
		$CanvasLayer/monedaEstrella3.show()
	elif Global.dragonCoins == 4:
		$CanvasLayer/monedaEstrella4.show()
