extends Spell

@export var speed : float = 1.0

@onready var game : Node2D = $"/root/Game"

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	global_position = data["click_position"]
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
	spell_cast.emit.call_deferred()

func _network_process(_input : Dictionary) -> void:
	check_damage_players()
	SyncManager.despawn(self)

func check_damage_players() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if (player.tile_position - Vector2i(global_position)) == Vector2i.ZERO:
			player.lose_turn(-1)
			return
