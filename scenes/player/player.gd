class_name Player extends Node2D
@export var server_player : bool = false
@export var spell_1 : PackedScene
@export var spell_2 : PackedScene
@export var spell_3 : PackedScene
@export var spell_slot_manager : VBoxContainer
var spells : Array

var spell_slots : Array
var selected_spell_slot : int = 0
var tilemap : LevelMap
var move_timer : NetworkTimer
var other_players : Array = []
var can_move : bool = false

func _ready() -> void:
	spell_slots = $MarginContainer/SpellSlots.get_children()
	update_spells()
	if multiplayer.is_server():
		if get_multiplayer_authority() == 1:
			spell_slot_manager.visible = true
	else:
		if get_multiplayer_authority() == multiplayer.get_unique_id():
			spell_slot_manager.visible = true

func _get_local_input() -> Dictionary:
	var input_vector : Vector2i = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		input_vector.y = -1
	elif Input.is_action_just_pressed("ui_down"):
		input_vector.y = 1
	elif Input.is_action_just_pressed("ui_right"):
		input_vector.x = 1
	elif Input.is_action_just_pressed("ui_left"):
		input_vector.x = -1
	if input_vector != Vector2i.ZERO && tilemap.query_location(input_vector * tilemap.tile_size + Vector2i(global_position)):
		input_vector = Vector2i.ZERO
	
	var clicked_cell : Vector2i = Vector2i.ZERO
	var cast_spell : bool = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		clicked_cell = tilemap.tilemap.local_to_map(tilemap.tilemap.get_local_mouse_position())
		cast_spell = true
	
	
	var input := {}
	if input_vector != Vector2i.ZERO:
		input["input_vector"] = input_vector
	if cast_spell:
		input["cast_spell"] = cast_spell
		input["spell_direction"] = clicked_cell - Vector2i(global_position/16)
	
	return input

func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("input_vector")
	input.erase("cast_spell")
	
	return input

func _network_process(input: Dictionary) -> void:
	if can_move:
		var movement_vector : Vector2 = Vector2(input.get("input_vector", Vector2.ZERO) * 16)
		if movement_vector != Vector2.ZERO:
			can_move = false
			position += Vector2(input.get("input_vector", Vector2.ZERO) * 16)
	
	
	if input.get("cast_spell", false):
		SyncManager.spawn("Spell", get_parent(), spell_slots[selected_spell_slot].spell, {position = global_position, "spell_direction" = input.get("spell_direction", Vector2i.ZERO)})
	
	set_visibility()

func _physics_process(_delta: float) -> void:
	set_visibility()

func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state : Dictionary) -> void:
	position = state["position"]

func set_visibility() -> void:
	var my_peer_id : int
	if multiplayer.is_server(): my_peer_id = 1
	else: my_peer_id = multiplayer.get_unique_id()
	
	if my_peer_id != get_multiplayer_authority():
		return
	
	var space_state = get_world_2d().direct_space_state
	for player in other_players:
		if player == self: continue
		
		var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
		var result = space_state.intersect_ray(query)
		if result:
			player.visible = false
			continue
		player.visible = true

func update_can_move() -> void:
	can_move = true

func update_spells() -> void:
	spells.append(spell_1)
	spells.append(spell_2)
	spells.append(spell_3)
	var i : int = 0
	for spell_slot in spell_slots:
		spell_slot.spell = spells[i]
		i = i + 1
