extends VSeparator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
func _on_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		show()
	else:
		hide()


func _on_button_hidden() -> void:
	hide()
