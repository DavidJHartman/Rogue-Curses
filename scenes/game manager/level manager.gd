class_name LevelMap extends Node2D

@export var spawns : Node2D
@export var tilemap : TileMapLayer
@onready var tile_size : int = tilemap.tile_set.tile_size.x

func get_spawn_points() -> Array:
	return spawns.get_children()

func query_location(new_position : Vector2) -> bool:
	var tile_position = Vector2i(new_position/tile_size)
	var tile_data = tilemap.get_cell_tile_data(tile_position)
	if tile_data:
		return tile_data.get_custom_data("Collide")
	return false
