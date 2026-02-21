extends Node2D

@export var player_scene : PackedScene
@export var tick_timer : NetworkTimer
@export var end_game_panel : PanelContainer
@export var sub_viewport : SubViewport

var character_sheets : Array
var current_map : LevelMap
var local_player : Player

@onready var players : Array = [player_scene.instantiate(), player_scene.instantiate()]
var living_players : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_game_panel.visible = false
	SyncManager.sync_stopped.connect(_on_SyncManager_sync_stopped)
	
	current_map = load("res://assets/maps/test_level.tscn").instantiate()
	sub_viewport.add_child(current_map)
	
	current_map.name = "Current Map"
	set_player_authority()
	spawn_players()
	
	Lobby.player_loaded.rpc()

func _setup_lobby() -> void:
	end_game_panel.visible = false
	current_map = load("res://assets/maps/test_level.tscn").instantiate()
	sub_viewport.add_child(current_map)
	
	current_map.name = "Current Map"
	set_player_authority()
	spawn_players()
	
	Lobby.player_loaded.rpc()

func start_game():
	tick_timer.start()

func spawn_players() -> void:
	print("Hey")
	var spawn_points = current_map.get_spawn_points()
	for i in (players.size()):
		sub_viewport.add_child(players[i])
		players[i].global_position = spawn_points[i].global_position
		players[i].name = "Player"
		players[i].tilemap = current_map
		players[i].tick_timer = tick_timer
		players[i].character_sheet = Lobby.character_sheets[Lobby.players[players[i].get_multiplayer_authority()]["class_index"]]
		players[i].dead.connect(player_dead)
		players[i].update_character_sheet()
		living_players += 1
	
	for player in players:
		player.other_players = players

@rpc("authority", "reliable")
func set_player_authority() -> void:
	players[0].set_multiplayer_authority(1)
	if multiplayer.is_server():
		local_player = players[0]
		players[1].set_multiplayer_authority(Lobby.players.keys()[1])
	else:
		local_player = players[1]
		players[1].set_multiplayer_authority(multiplayer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func ready_to_replay() -> void:
	if multiplayer.is_server():
		if Lobby.check_players_ready() == false:
			return
		

@rpc("authority", "call_local", "reliable")
func reset_lobby() -> void:
	current_map.queue_free()
	_setup_lobby()

func end_round() -> void:
	if multiplayer.is_server():
		SyncManager.stop()

func player_dead() -> void:
	living_players -= 1
	if living_players <= 1:
		end_round()

func _on_SyncManager_sync_stopped():
	end_game_panel.visible = true


func _on_exit_pressed() -> void:
	if not SyncManager.started:
		SyncManager.stop()
	#Lobby.disconnect_from_server()

func _on_restart_pressed() -> void:
	
	reset_lobby.rpc()
