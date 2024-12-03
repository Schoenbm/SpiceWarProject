extends Sprite2D

class_name OverlayPlanet
const my_scene : PackedScene = preload("res://Assets/Prefab/overlayplanet.tscn")

var player : Player

static func create_overlay(aPlayer):
	var overlay = my_scene.instantiate()
	overlay.player = aPlayer
	return overlay
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(player.get_finger_pos())
	pass
