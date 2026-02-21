extends Spell

@export var remote_visibility : RemoteVisibility
@export var spore_cloud : PackedScene

@onready var game : Node2D = $"/root/Game"

var player : Player
var players : Array

var tile_position : Vector2i

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)
	players = get_tree().get_nodes_in_group("players")

func _network_spawn(data : Dictionary) -> void:
	player = get_node(data["caster"])
	tile_position = data['cast_position']
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8))
	remote_visibility.my_player = player

func _network_despawn() -> void:
	remote_visibility.clean_up_on_despawn()

func _process(_delta : float) -> void:
	set_visibility()

func _network_process(_input: Dictionary) -> void:
	_check_damage_player()

func _check_damage_player() -> void:
	for i in players.size():
		if players[i] == player:
			continue
		if (players[i].tile_position - tile_position).length() < 1.42:
			_explode()

func _explode() -> void:
	var tilemap : LevelMap = player.tilemap
	for x in range(-1, 2):
		for y in range(-1, 2):
			var check_pos : Vector2i = Vector2i(x, y) + tile_position
			if tilemap.query_location(check_pos):
				continue
			SyncManager.spawn("spore cloud",  $/root/Game/SubViewportContainer/SubViewport, spore_cloud, {position = check_pos})
	SyncManager.despawn(self)

func decrement_health() -> void:
	_explode()
