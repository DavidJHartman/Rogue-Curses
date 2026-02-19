extends Spell

@onready var game : Node2D = $"/root/Game"

func _network_spawn(data : Dictionary) -> void:
	global_position = Vector2(data['click_position'] * 16) + Vector2(8,8)

func _save_state() -> Dictionary:
	return {
		global_position = global_position
	}

func _load_state(state : Dictionary) -> void:
	global_position = state['global_position']
