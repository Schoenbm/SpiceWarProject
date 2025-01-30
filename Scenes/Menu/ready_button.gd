extends Button

func _ready() -> void:
	disabled = false
	MultiplayerManager.player_connected.connect(_on_player_connected)

func _on_player_connected(pd : PlayerData) -> void:
	disabled = true
	await get_tree().create_timer(2).timeout
	disabled = false
