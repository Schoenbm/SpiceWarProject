extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerManager.sync_lost_label = self
	hide()
