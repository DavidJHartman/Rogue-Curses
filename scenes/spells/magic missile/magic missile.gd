extends Spell

@export var speed : float = 1.0
@export var ticks_to_charge : int = 3
var direction : Vector2 = Vector2.ZERO

func _network_process(_input: Dictionary) -> void:
	print("Processing?")
	print(get_path())
	if not active:
		return
	global_position += direction.normalized() * speed

func receive_input(cast_position : Vector2, tile_position : Vector2i) -> void:
	print("Hey?")
	get_parent().reset_spell_slot()
	reparent($/root/Game)
	direction = tile_position - Vector2i(cast_position/16)
	global_position = Vector2(cast_position) + (direction.normalized() * 24)
	active = true
	visible = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	print("Here?")
	SyncManager.despawn.call_deferred(self)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("Here?")
	SyncManager.despawn.call_deferred(self)
