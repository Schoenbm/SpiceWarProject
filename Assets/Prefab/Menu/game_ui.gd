extends Control

class_name SpiceUI

var player : Player
@export var label : Label

func set_player(p : Player):
	player = p
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(player.spices)
