class_name Spell extends Node2D

var active : bool = false

signal spell_cast
func _network_process(_input: Dictionary) -> void:
	return

func _network_spawn(_data : Dictionary) -> void:
	active = false
	visible = false
	global_position = Vector2(-1000, -1000)

func receive_input(_cast_position : Vector2, _tile_position : Vector2i) -> void:
	return

func _save_state() -> Dictionary:
	return{
		
	}

func _load_state(state : Dictionary) -> void:
	pass
