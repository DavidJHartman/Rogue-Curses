extends Spell

@export var speed : float = 1.0

@onready var game : Node2D = $"/root/Game"

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)
	SyncManager.set_synced(self, "direction", direction)
	SyncManager.set_synced(self, "active", active)
	

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	direction = data['click_position'] - data['cast_position']
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8)) + (direction.normalized() * 16)
	active = true
	
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
	spell_cast.emit.call_deferred()

func _process(_delta : float) -> void:
	set_visibility()

func _network_process(_input: Dictionary) -> void:
	if game.current_map.query_location(global_position):
		SyncManager.despawn(self)
		return
	
	global_position += direction.normalized() * speed
	check_damage_players()

func check_damage_players() -> void:
	var tile_position : Vector2i = game.current_map.tilemap.local_to_map(global_position)
	for player in get_tree().get_nodes_in_group("players"):
		if (player.tile_position - tile_position) == Vector2i.ZERO:
			player.decrement_health()
			SyncManager.despawn(self)
			return
