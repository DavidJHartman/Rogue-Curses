class_name MainMenu extends Node2D

@export var connection_panel : PanelContainer
@export var lobby_panel : PanelContainer
@export var host_field : LineEdit
@export var port_field : LineEdit
@export var name_field : LineEdit
@export var message_label : Label
@export var player_1_name : Label
@export var player_2_name : Label
@export var player_1_ready : Label
@export var player_2_ready : Label
@export var exit_game_button : Button
@export var start_game_button : Button
@export var ready_button : Button

var player_ready : bool = false
var ready_dict : Dictionary = {false : "Not Ready", true : "Ready"}


func _ready() -> void:
	Lobby.player_connected.connect(_player_connected)
	Lobby.server_disconnected.connect(_server_disconnected)
	Lobby.player_disconnected.connect(_player_disconnected)
	Lobby.ready_change.connect(_update_ready_status)
	Lobby.server_disconnected.connect(_reload_scene)
	SyncManager.sync_started.connect(_on_SyncManager_sync_started)
	SyncManager.sync_stopped.connect(_on_SyncManager_sync_stopped)
	player_1_name.text = Lobby.player_info["name"]
	
	connection_panel.visible = true
	lobby_panel.visible = false

## Setup code for ENet Multiplayer Server host.
func _on_host_game_pressed() -> Error:
	var error = Lobby.create_game()
	if error:
		message_label.text = error_string(error)
		return error
	connection_panel.visible = false
	Lobby.player_info["name"] = name_field.text
	message_label.text = "Listening..."
	_lobby_menu_initialize()
	return OK

## Setup code for ENet Multiplayer Server Client
func _on_join_game_pressed() -> Error:
	var error = Lobby.join_game(host_field.text)
	if error:
		message_label.text = error_string(error)
		return error
	connection_panel.visible = false
	message_label.text = "Connecting..."
	Lobby.player_info["name"] = name_field.text
	_lobby_menu_initialize()
	return OK

func _lobby_menu_initialize() -> void:
	lobby_panel.visible = true
	player_1_name.text = Lobby.player_info["name"]
	if multiplayer.is_server():
		start_game_button.visible = true
		ready_button.visible = false
	else:
		start_game_button.visible = false
		ready_button.visible = true

func _player_connected(_peer_id : int, _player_info) -> void:
	message_label.text = "Connected!"
	player_2_name.text = Lobby.players[_peer_id]["name"]

func _server_disconnected() -> void:
	message_label.text = "Server disconnected."

func _player_disconnected(_peer_id : int) -> void:
	message_label.text = "Player disconnected."

func _on_start_game_pressed() -> void:
	if not multiplayer.is_server():
		return
	
	if Lobby.check_players_ready() == false:
		return
	
	Lobby.start_sync_manager()

func _on_name_field_text_changed(new_text: String) -> void:
	Lobby.player_info["name"] = new_text

func _on_ready_toggle_pressed() -> void:
	Lobby.self_ready = not Lobby.self_ready
	Lobby.ready_toggle.rpc(Lobby.self_ready)
	player_1_ready.text = ready_dict[Lobby.self_ready]

func _update_ready_status(_player_name : String, ready_status : bool) -> void:
	player_2_ready.text = ready_dict[ready_status]

func _on_reset_pressed() -> void:
	Lobby._disconnect_from_session()

func _reload_scene() -> void:
	get_tree().reload_current_scene()

func _on_SyncManager_sync_started() -> void:
	message_label.text = "Started!"

func _on_SyncManager_sync_stopped() -> void:
	pass
