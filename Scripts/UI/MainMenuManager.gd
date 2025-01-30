extends Control

@export var LobbyMenu : LobbyManager
@export var MainMenu : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_host_pressed() -> void:
	LobbyMenu.show()
	MainMenu.hide()
	MultiplayerManager.solo = false
	MultiplayerManager.create_game()
	LobbyMenu.host_ready()
	


func _on_join_pressed() -> void:
	LobbyMenu.show()
	MainMenu.hide()
	MultiplayerManager.solo = false
	MultiplayerManager.join_game()


func _on_solo_pressed() -> void:
	MultiplayerManager.solo = true
	get_tree().change_scene_to_file("res://Scenes/1v1.tscn")
