extends TileMap

var tile_size = tile_set.tile_size
var half_tile_size = tile_size/2

var grid_size = get_used_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_cell_empty(position : Vector2) -> bool:
	if get_cell_source_id(0, position) == -1:
		return true
	return false
