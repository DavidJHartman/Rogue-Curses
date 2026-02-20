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

func receive_input(_data : Dictionary) -> void:
	return

func _save_state() -> Dictionary:
	return{
		
	}

func _load_state(_state : Dictionary) -> void:
	pass
