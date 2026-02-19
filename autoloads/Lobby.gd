extends Node

@export var character_sheets_folder : String = "res://scenes/player/character sheets/"
var character_sheets : Array

const PORT : int = 9999
const DEFAULT_SERVER_IP : String = "127.0.0.1"
const MAX_CONNECTIONS : int = 1
const LOG_FILE_DIRECTORY = 'user://detailed_logs'

var logging_enabled : bool = true

var players = {}
var players_loaded : int = 0

var player_info = {"name": "Name", "ready": false, "class_index" : 0}

var self_ready : bool = false

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal ready_change(player_name, player_ready)

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	SyncManager.connect("sync_started", _on_SyncManager_sync_started)
	SyncManager.connect("sync_stopped", _on_SyncManager_sync_stopped)
	SyncManager.sync_error.connect(_disconnect_from_session)
	_load_all_character_sheets()

func join_game(address : String = "") -> Error:
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	return OK

func create_game() -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, Lobby.MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	return OK

func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path) -> void:
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size() - 1:
			$/root/Game.start_game.rpc()
			players_loaded = 0

func disconnect_from_server() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func _on_player_connected(peer_id : int) -> void:
	_register_player.rpc_id(peer_id, player_info)
	SyncManager.add_peer(peer_id)

@rpc("any_peer", "reliable")
func _register_player(new_player_info) -> void:
	var new_peer_id = multiplayer.get_remote_sender_id()
	players[new_peer_id] = new_player_info
	players[new_peer_id]["ready"] = false
	player_connected.emit(new_peer_id, new_player_info)

func _on_player_disconnected(peer_id : int) -> void:
	players.erase(peer_id)
	player_disconnected.emit(peer_id)
	SyncManager.remove_peer(peer_id)

func _on_connected_ok() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	_disconnect_from_session("")

@rpc("any_peer", "reliable")
func ready_toggle(player_ready : bool):
	players[multiplayer.get_remote_sender_id()]["ready"] = player_ready
	ready_change.emit(players[multiplayer.get_remote_sender_id()]["name"], player_ready)

func _on_server_disconnected() -> void:
	_disconnect_from_session("")

func start_sync_manager() -> void:
	if multiplayer.is_server():
		await get_tree().create_timer(2.0).timeout
		SyncManager.start()
		load_game.rpc("res://scenes/game manager/game.tscn")

func check_players_ready() -> bool:
	for id in players:
		if id == 1:
			continue
		if players[id]["ready"] == false:
			return false
	return true

func _disconnect_from_session(msg : String) -> void:
	print(msg)
	SyncManager.stop()
	SyncManager.clear_peers()
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()

func _update_player_info(key : String, data) -> void:
	player_info[key] = data
	if multiplayer.is_server():
		players[1] = player_info
	else:
		players[multiplayer.get_unique_id()] = player_info

func _on_SyncManager_sync_started() -> void:
	if logging_enabled:
		pass
		var dir : DirAccess = DirAccess.open(LOG_FILE_DIRECTORY)
		if not dir:
			dir = DirAccess.open("user://")
			dir.make_dir(LOG_FILE_DIRECTORY)
		
		var date = Time.get_date_dict_from_system()
		var time = Time.get_time_dict_from_system()
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log"%[
			date['year'],
			date['month'],
			date['day'],
			time['hour'],
			time['minute'],
			time['second'],
			multiplayer.get_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

func _on_SyncManager_sync_stopped() -> void:
	if logging_enabled:
		SyncManager.stop_logging()

func _load_all_character_sheets() -> void:
	var dir : DirAccess = DirAccess.open(character_sheets_folder)
	character_sheets.resize(4)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		
		while file_name != "":
			# Check if the current item is a file (not a directory)
			if not dir.current_is_dir():
				# Add the full path to the list
				var new_character_sheet : CharacterSheet = ResourceLoader.load(character_sheets_folder.path_join(file_name))
				character_sheets[new_character_sheet.character_index] = new_character_sheet
			
			 # Move to the next item
			file_name = dir.get_next()
		
		# Stop iterating (optional, as the loop condition handles it)
		dir.list_dir_end()
