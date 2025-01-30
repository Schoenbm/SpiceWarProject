extends Control

class_name LobbyManager

@export var StartButton : Button
@export var PlayerList : Control
@export var Lobby : Control

var PlayerDataArray : Array[LobbyPlayerData]

# Called when the node enters the scene tree for the first time.
var ready_count = 0
var number_of_players_in_lobby = 0


var index_dict = {}


func _ready():
	MultiplayerManager.player_connected.connect(_on_player_connected)
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	MultiplayerManager.player_modified.connect(_on_player_modified)

	var i = 0
	for child in PlayerList.get_children():
		if(child is LobbyPlayerData):
			PlayerDataArray.push_back(child as LobbyPlayerData)
			i += 1

func host_ready() -> void:
	PlayerDataArray[0].init(LocalPlayerData)
	number_of_players_in_lobby += 1


func init_player_data( pd : PlayerData):
	PlayerDataArray[pd.player_id - 1].init(pd)

func get_index_of_id(id):
	return index_dict[id]

func _on_ready_button_toggled(toggled_on: bool) -> void:
	player_ready.rpc(toggled_on, LocalPlayerData.player_id)


func get_lobby_player_data(id : int):
	return(PlayerDataArray[id -1])

@rpc("any_peer","reliable", "call_local")
func player_ready(bol : bool, id : int):
	get_lobby_player_data(id).color_player_ready(bol)
	if(bol):
		change_ready_count(1)
	else:
		change_ready_count(-1)

func change_ready_count(value):
	ready_count += value
	if(ready_count >= number_of_players_in_lobby):
		StartButton.disabled = false
	else:
		StartButton.disabled = true

func _on_player_connected(pd : PlayerData):
	number_of_players_in_lobby += 1
	init_player_data(pd)
	change_ready_count(0)

func _on_player_disconnected(pds : Dictionary):
	number_of_players_in_lobby -= 1
	PlayerDataArray[number_of_players_in_lobby].clear()
	for pd in pds.values():
		init_player_data(pd)
		
func _on_start_button_button_down() -> void:
	MultiplayerManager.load_game()
	

func _on_player_modified(pd : PlayerData):
	init_player_data(pd)
