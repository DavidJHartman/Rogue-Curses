extends Spell

@export var speed : float = 1.0

@onready var game : Node2D = $"/root/Game"

var player : Player

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)

func _network_spawn(data : Dictionary) -> void:
	player = get_node(data["caster"])
	parent_nodepath = data["spellslot_path"]
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8))
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)

func _process(_delta : float) -> void:
	set_visibility()

func set_visibility() -> void:
	var my_peer_id : int
	if multiplayer.is_server(): my_peer_id = 1
	else: my_peer_id = multiplayer.get_unique_id()
	
	var space_state = get_world_2d().direct_space_state
	var position_to_check : Vector2 = Vector2.ZERO
	for _player in get_tree().get_nodes_in_group("players"):
		if _player.get_multiplayer_authority() == my_peer_id:
			position_to_check = _player.global_position
	
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

func receive_input(_data : Dictionary) -> void:
	player.global_position = global_position
	spell_cast.emit()
	SyncManager.despawn(self)
