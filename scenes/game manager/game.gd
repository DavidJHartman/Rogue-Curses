extends Node2D

@export var player_scene : PackedScene
@export var tick_timer : NetworkTimer
@export var spell_slots : VBoxContainer
var character_sheets : Array
var current_map : LevelMap
var local_player : Player

@onready var players : Array = [player_scene.instantiate(), player_scene.instantiate()]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_map = load("res://assets/maps/test_level.tscn").instantiate()
	add_child(current_map)
	
	current_map.name = "Current Map"
	set_player_authority()
	spawn_players()
	Lobby.player_loaded.rpc()

func start_game():
	tick_timer.start()

func spawn_players() -> void:
	var spawn_points = current_map.get_spawn_points()
	for i in (players.size()):
		add_child(players[i])
		players[i].global_position = spawn_points[i].global_position
		players[i].name = "Player"
		players[i].tilemap = current_map
		players[i].tick_timer = tick_timer
		players[i].character_sheet = Lobby.character_sheets[Lobby.players[players[i].get_multiplayer_authority()]["class_index"]]
		
		players[i].update_character_sheet()
	
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
