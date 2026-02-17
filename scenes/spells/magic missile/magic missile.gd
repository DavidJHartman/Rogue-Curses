extends Spell

@export var speed : float = 1.0
@export var ticks_to_charge : int = 3
var direction : Vector2 = Vector2.ZERO

func _network_process(_input: Dictionary) -> void:
	if not active:
		return
	global_position += direction.normalized() * speed

func receive_input(cast_position : Vector2, tile_position : Vector2i) -> void:
	get_parent().reset_spell_slot()
	reparent($/root/Game)
	direction = tile_position - Vector2i(cast_position/16)
	global_position = Vector2(cast_position) + (direction.normalized() * 24)
	active = true
	visible = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	SyncManager.despawn.call_deferred(self)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	SyncManager.despawn.call_deferred(self)

func _save_state() -> Dictionary:
	return {
		"global_position" : global_position,
		"direction" : direction
	}

func _load_state(state : Dictionary) -> void:
	global_position = state["global_position"]
	direction = state["direction"]
