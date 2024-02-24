extends Node2D

var player_scene := preload("res://scenes/characters/player.tscn")
var turn_timer_scene := preload("res://scenes/game state/turn_timer.tscn")
var players := {}
var alive_players := {}
var ready_players := {}
var player_character_sheets := {}

var my_player 

signal start_new_game

# Called when the node enters the scene tree for the first time.
func _ready():
	SyncManager.connect("sync_stopped", _on_SyncManager_sync_stopped)
	connect("tree_exited", _on_tree_exited)
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("authority", "call_local")
func start_game():
	SyncManager.spawn("Turn Timer", self, turn_timer_scene).get_child(0).connect("timeout", my_player.set_can_move)

func _on_tree_exited() -> void:
	SyncManager.stop_logging()

func _on_SyncManager_sync_stopped() -> void:
	SyncManager.stop_logging()

func setup_game(match_info) -> void:
	set_multiplayer_authority(1)
	players = match_info["Players"]
	alive_players = players
	player_character_sheets = match_info["Character Sheets"]
	for id in players:
		var new_player = player_scene.instantiate()
		new_player.name = str(id)
		$"%Players".add_child(new_player)
		if id == 1:
			new_player.set_multiplayer_authority(1)
			new_player.setup(player_character_sheets[1])
		else:
			if multiplayer.is_server():
				new_player.set_multiplayer_authority(id)
			else:
				new_player.set_multiplayer_authority(multiplayer.get_unique_id())
			new_player.setup(player_character_sheets[id])
		new_player.position = $"%Spawn Points".find_child(str(id), false).position
		new_player.grid_position = Vector2i(new_player.position) / $"map".tile_size
	
	
	var my_id = SyncManager.network_adaptor.get_unique_id()
	my_player = $"%Players".get_node(str(my_id))
	my_player.player_controlled = true
	my_player.add_camera()
	
	$"Player HUD".my_player = my_player
	
	finished_setup.rpc(my_id)

@rpc("any_peer", "call_local")
func finished_setup(_id) -> void:
	ready_players[_id] = players[_id]
	visible = true
	if multiplayer.is_server():
		if ready_players.size() == players.size():
			start_game.rpc()
