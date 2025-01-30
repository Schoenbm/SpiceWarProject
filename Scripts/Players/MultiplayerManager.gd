extends Node

var players: Dictionary

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

signal player_modified(player_info : PlayerData)
signal player_connected(player_info : PlayerData)
signal player_disconnected(pds : Dictionary)
signal server_disconnected
signal lobby_index_order
signal game_loaded

var solo = true

var sync_lost_label : Label

const LOG_FILE_DIRECTORY = "user://detailed_logs"

var logging_enabled = true

var players_loaded = 0
func _ready():	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	SyncManager.sync_error.connect(_on_sync_error)
	SyncManager.sync_lost.connect(_on_sync_lost)
	SyncManager.sync_regained.connect(_on_sync_regained)
	SyncManager.sync_started.connect(_on_sync_started)
	SyncManager.sync_stopped.connect(_on_sync_stopped)
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.



func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer



func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	LocalPlayerData.player_id = 1
	players[peer.get_unique_id()] = LocalPlayerData


	

@rpc("any_peer","reliable")
func _register_new_player(new_player_info, id):
	var new_player_data = PlayerData.get_dict_as_pd(new_player_info)
	new_player_data.player_id = players.size() +1
	for player_id in players.keys():
		_send_self_to_new_player.rpc_id(player_id, id)
	_register_player.rpc(new_player_data.get_pd_as_dict(), id)
	
@rpc("any_peer", "reliable","call_local")
func _register_player(new_player_info, id):
	var new_player_data = PlayerData.get_dict_as_pd(new_player_info)
	if(id == multiplayer.multiplayer_peer.get_unique_id()):
		LocalPlayerData.player_id = new_player_data.player_id
	players[id] = new_player_data
	if(id != multiplayer.get_unique_id()):
		SyncManager.add_peer(id)
	player_connected.emit(new_player_data)
	if(multiplayer.is_server()):
		await get_tree().create_timer(2.0).timeout



@rpc("authority","reliable","call_local")
func _send_self_to_new_player(id):
	_register_player.rpc_id(id, LocalPlayerData.get_pd_as_dict(), multiplayer.multiplayer_peer.get_unique_id())
	
func _on_player_disconnected(id):
	on_disconnect_update_players_ids(id)
	players.erase(id)
	player_disconnected.emit(players)
	SyncManager.remove_peer(id)


func _on_connected_ok():
	_register_new_player.rpc_id(1, LocalPlayerData.get_pd_as_dict(), multiplayer.multiplayer_peer.get_unique_id())

func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	players.clear()
	stop_match()
	multiplayer.multiplayer_peer = null


	#Load Scene 0

func on_disconnect_update_players_ids(id):
	var dc_player_id = players[id].player_id
	for player in players.values():
		if( player.player_id > dc_player_id):
			player.player_id -= 1
			if(players.find_key(player) == multiplayer.multiplayer_peer.get_unique_id()):
				LocalPlayerData.player_id -= 1

func local_alliance_change():
	on_peer_pd_alliance_change.rpc(multiplayer.multiplayer_peer.get_unique_id(), LocalPlayerData.player_alliance)
	
@rpc("any_peer","reliable","call_remote")
func on_peer_pd_alliance_change(id, alliance):
	players[id].player_alliance = alliance
	print(players[id].player_name + str(players[id].player_alliance))
	player_modified.emit(players[id])

func load_game():
	if(multiplayer.is_server()):
		load_game_scene.rpc("res://Scenes/1v1.tscn")

@rpc("authority","reliable","call_local")
func load_game_scene(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)
	
@rpc("authority","call_local","reliable")
func start_game():
	game_loaded.emit()

	
func player_loaded():
	peer_loaded.rpc_id(1)
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func peer_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			SyncManager.start()
			start_game.rpc()
			players_loaded = 0

func stop_match():
	SyncManager.stop()
	SyncManager.clear_peers()
	multiplayer.multiplayer_peer.close()
	server_disconnected.emit()
	get_tree().change_scene_to_file("res://Scenes/Menu/menu.tscn")

func _on_player_connected(id):
	pass

func _on_sync_started():
	if(logging_enabled):
		if not DirAccess.dir_exists_absolute(LOG_FILE_DIRECTORY):
			DirAccess.make_dir_absolute(LOG_FILE_DIRECTORY)
		var datetime = Time.get_datetime_string_from_system()
		var log_file = datetime + "_peer_str" + str(multiplayer.multiplayer_peer.get_unique_id()) + ".log"
		log_file = log_file.replace(':','_')
			
		SyncManager.start_logging(LOG_FILE_DIRECTORY +"/" + log_file)
func _on_sync_stopped():
	SyncManager.stop_logging()
	
func _on_sync_error(msg : String):
	print("Error :" + msg)
	sync_lost_label.hide()
	stop_match()
	
func _on_sync_lost():
	if(sync_lost_label != null):
		sync_lost_label.show()
func _on_sync_regained():
	if(sync_lost_label != null):
		sync_lost_label.hide()
