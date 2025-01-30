extends LineEdit

func _on_text_submitted(new_text: String) -> void:
	LocalPlayerData.player_name = new_text


func _on_text_changed(new_text: String) -> void:
	LocalPlayerData.player_name = new_text
