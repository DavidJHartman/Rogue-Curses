class_name Spell extends Node2D

var active : bool = false
var parent_nodepath : NodePath

signal spell_cast

func _network_spawn_preprocess(data : Dictionary) -> Dictionary:
	data['spellslot_path'] = data['spellslot'].get_path()
	data.erase('spellslot')
	return data

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]

func _network_process(_input: Dictionary) -> void:
	return

func _ready() -> void:
	global_position = Vector2.ZERO
	active = false
	visible = true

func _check_damage_player() -> void:
	return

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

func receive_input(_data : Dictionary) -> void:
	return

func _save_state() -> Dictionary:
	return{
		
	}

func _load_state(_state : Dictionary) -> void:
	pass
