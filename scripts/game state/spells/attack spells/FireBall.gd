extends Node2D

func _network_spawn(data: Dictionary) -> void:
	global_position = data['position']
