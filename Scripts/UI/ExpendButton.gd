extends Button

var up : bool = false
@export var icon_up = Image
@export var icon_down = Image

signal go_up(bool)
# Called when the node enters the scene tree for the first time.

func _on_pressed() -> void:
	if(up):
		set_button_icon(icon_down)
	else:
		set_button_icon(icon_up)
	up = !up
	go_up.emit(up)
