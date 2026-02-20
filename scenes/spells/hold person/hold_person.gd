extends Spell

@export var speed : float = 1.0

@onready var game : Node2D = $"/root/Game"

func _ready() -> void:
	SyncManager.scene_despawned.connect(_on_SyncManager_scene_despawned)
	SyncManager.scene_spawned.connect(_on_SyncManager_scene_spawned)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	global_position = data["click_position"]
	if not active:
		spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
		active = true
	spell_cast.emit.call_deferred()

func _network_process(_input : Dictionary) -> void:
	check_damage_players()
	SyncManager.despawn(self)

func check_damage_players() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if (player.tile_position - Vector2i(global_position)) == Vector2i.ZERO:
			player.lose_turn(-1)
			return

func _on_SyncManager_scene_spawned(_name, spawned_node, _scene, _data) -> void:
	if spawned_node == self and not active:
		spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)

func _on_SyncManager_scene_despawned(_name, spawned_node) -> void:
	if spawned_node == self and not active:
		spell_cast.disconnect(get_node(parent_nodepath).reset_spell_slot)

func _save_state() -> Dictionary:
	return {
		global_position = global_position,
	}

func _load_state(state : Dictionary) -> void:
	global_position = state['global_position']
	active = state['active']
