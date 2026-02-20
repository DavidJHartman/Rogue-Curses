extends Spell

@export var speed : float = 1.0

@onready var game : Node2D = $"/root/Game"

var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	SyncManager.scene_despawned.connect(_on_SyncManager_scene_despawned)
	SyncManager.scene_spawned.connect(_on_SyncManager_scene_spawned)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	direction = data['click_position'] - data['cast_position']
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8)) + (direction.normalized() * 16)
	if not active:
		spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
		active = true
	
	spell_cast.emit.call_deferred()

func _process(_delta : float) -> void:
	set_visibility()

func set_visibility() -> void:
	var my_peer_id : int
	if multiplayer.is_server(): my_peer_id = 1
	else: my_peer_id = multiplayer.get_unique_id()
	
	var space_state = get_world_2d().direct_space_state
	var position_to_check : Vector2 = Vector2.ZERO
	for player in get_tree().get_nodes_in_group("players"):
		if player.get_multiplayer_authority() == my_peer_id:
			position_to_check = player.global_position
	
	var query = PhysicsRayQueryParameters2D.create(global_position, position_to_check)
	var result = space_state.intersect_ray(query)
	if result:
		visible = false
		return
	visible = true

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

func _on_SyncManager_scene_spawned(_name, spawned_node, _scene, _data) -> void:
	if spawned_node == self and not active:
		spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)

func _on_SyncManager_scene_despawned(_name, spawned_node) -> void:
	if spawned_node == self and not active:
		spell_cast.disconnect(get_node(parent_nodepath).reset_spell_slot)

func _save_state() -> Dictionary:
	return {
		global_position = global_position,
		direction = direction,
		active = active
	}

func _load_state(state : Dictionary) -> void:
	global_position = state['global_position']
	direction = state['direction']
	active = state['active']
