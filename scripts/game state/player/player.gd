extends Area2D

var current_character := "Grinney"

@export var player_controlled := false
var delta_v := Vector2.ZERO
var look_at_vector := 0
var can_move := true


var grid_position : Vector2i

signal player_can_move

@onready var grid_map := $"../../map"
@onready var player_hud := $"../../Player HUD"
@onready var animation_player := $"AnimationPlayer"
@onready var sprite := $"Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("player_can_move", player_hud.move_label_visible)
	animation_player.play(current_character)

func _get_local_input() -> Dictionary:
	var input_vector := Vector2.ZERO
	if can_move:
		input_vector = Input.get_vector("Left", "Right", "Up", "Down")
		if input_vector != Vector2.ZERO:
			can_move = false
			emit_signal("player_can_move", false)
	
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	return input

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	
	return input

func _network_process(input: Dictionary) -> void:
	var movement_input = Vector2i(input.get("input_vector", Vector2i.ZERO))
	var test_position = grid_position + movement_input
	
	if movement_input != Vector2i.ZERO:
		if grid_map.is_cell_empty(test_position):
			grid_position = test_position
			position = grid_position * grid_map.tile_size + grid_map.half_tile_size

func _save_state() -> Dictionary:
	return {
		grid_position = grid_position,
	}

func setup(_character_sheet) -> void:
	animation_player.play(_character_sheet["character_name"])
	sprite.modulate = _character_sheet["color"]

func _load_state(state : Dictionary ) -> void:
	grid_position = state["grid_position"]

func add_camera() -> void:
	var new_camera = Camera2D.new()
	new_camera.zoom = Vector2(2,2)
	add_child(new_camera)
	new_camera.name = "Camera2D"

func set_can_move():
	can_move = true
	emit_signal("player_can_move", true)
