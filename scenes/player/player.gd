class_name Player extends Node2D
@export var server_player : bool = false
@export var character_sheet : CharacterSheet
@export var spell_slot_manager : VBoxContainer
@export var sprite : Sprite2D

@onready var spell_slots : Array = $%SpellSlots.get_children()
var selected_spell_slot : int = 0
var tilemap : LevelMap
var tick_timer : NetworkTimer
var other_players : Array = []
var can_move : bool = false
var frame_1 : bool = true

func update_character_sheet() -> void:
	tick_timer.timeout.connect(update_can_move)
	tick_timer.timeout.connect(update_animation)
	
	sprite.texture = character_sheet.sprite_sheet
	sprite.region_rect = character_sheet.sprite_float_rect[character_sheet.character_index]
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
	
	if Input.is_action_just_pressed("spell_1"):
		selected_spell_slot = 1
	if Input.is_action_just_pressed("spell_2"):
		selected_spell_slot = 2
	if Input.is_action_just_pressed("spell_3"):
		selected_spell_slot = 3
	if Input.is_action_just_pressed("spell_4"):
		selected_spell_slot = 4
	
	
	if input_vector != Vector2i.ZERO && tilemap.query_location(input_vector * tilemap.tile_size + Vector2i(global_position)):
		input_vector = Vector2i.ZERO
	
	var clicked_cell : Vector2i = Vector2i.ZERO
	var cast_spell : bool = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		clicked_cell = tilemap.tilemap.local_to_map(tilemap.tilemap.get_local_mouse_position())
		spell_slots[selected_spell_slot].button_pressed()
	
	
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
	var spells : Array = character_sheet.get_spells()
	var i : int = 0
	for spell_slot in spell_slots:
		spell_slot.spell = spells[i]
		tick_timer.timeout.connect(spell_slot.increment_ready)
		i = i + 1

func update_animation() -> void:
	if frame_1:
		sprite.region_rect.position.x += character_sheet.sprite_size
		frame_1 = false
	else:
		sprite.region_rect.position.x -= character_sheet.sprite_size
		frame_1 = true
