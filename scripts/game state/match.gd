extends Node2D

var current_map


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func scene_setup(match_info):
	print("Setup scene!")
	var map_path = "res://scenes/levels/" + match_info["Map Name"]
	current_map = load(map_path).instantiate()
	add_child(current_map)
	current_map.setup_game(match_info)
