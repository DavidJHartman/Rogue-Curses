extends Node2D

@onready var grid_map = $"../../map"
@onready var cursor_sprite = $"cursor sprite"

var map_position := Vector2.ZERO
var current_position := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	current_position = grid_map.get_local_mouse_position()
	map_position = grid_map.local_to_map(current_position)
	position = grid_map.map_to_local(map_position)
	cursor_sprite.texture.size = grid_map.tile_size

func _unhandled_input(event):
	current_position = grid_map.get_local_mouse_position()
	map_position = grid_map.local_to_map(current_position)
	position = grid_map.map_to_local(map_position)
