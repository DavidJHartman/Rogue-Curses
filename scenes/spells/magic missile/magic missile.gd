extends Node2D

@export var speed : float = 1.0
@export var ticks_to_charge : int = 3
var direction : Vector2i = Vector2i.ZERO
var direction_normal : Vector2

func _network_spawn(data: Dictionary) -> void:
	global_position = data['position']
	direction = data['spell_direction']
	direction_normal = direction / direction.length()
	global_position += direction_normal * 16 * 1.4

func _network_process(_input: Dictionary) -> void:
	global_position += direction_normal * speed

func _on_area_2d_body_entered(_body: Node2D) -> void:
	SyncManager.despawn.call_deferred(self)


func _on_area_2d_area_entered(_area: Area2D) -> void:
	SyncManager.despawn.call_deferred(self)

func get_texture() -> Texture2D:
	return $Sprite2D.texture
