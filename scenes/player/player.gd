class_name Player extends Node2D
@export var server_player : bool = false
@export var character_sheet : CharacterSheet
@export var spell_slot_manager : VBoxContainer
@export var sprite : Sprite2D

@onready var spell_slots : Array = $%SpellSlots.get_children()
var selected_spell_slot : int = 0
var tile_position : Vector2i
var tilemap : LevelMap
var tick_timer : NetworkTimer
var other_players : Array = []
var can_move : bool = false
var frame_1 : bool = true

func update_character_sheet() -> void:
	tick_timer.timeout.connect(update_can_move)
	tick_timer.timeout.connect(update_animation)
	tile_position = tilemap.tilemap.local_to_map(global_position)
	sprite.position = Vector2.ZERO
	
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
	var select_spell : bool = false
	var new_spell_slot : int
	if Input.is_action_just_pressed("move_up"):
		input_vector.y = -1
	elif Input.is_action_just_pressed("move_down"):
		input_vector.y = 1
	elif Input.is_action_just_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_just_pressed("move_left"):
		input_vector.x = -1
	
	if Input.is_action_just_pressed("spell_1"):
		new_spell_slot = 0
		select_spell = true
	if Input.is_action_just_pressed("spell_2"):
		new_spell_slot = 1
		select_spell = true
	if Input.is_action_just_pressed("spell_3"):
		new_spell_slot = 2
		select_spell = true
	if Input.is_action_just_pressed("spell_4"):
		new_spell_slot = 3
		select_spell = true
	
	
	if input_vector != Vector2i.ZERO && tilemap.query_location(input_vector * tilemap.tile_size + Vector2i(global_position)):
		input_vector = Vector2i.ZERO
	
	var clicked_cell : Vector2i = Vector2i.ZERO
	var cast_spell : bool = false
	if Input.is_action_just_pressed("lmb_click"):
		cast_spell = true
		clicked_cell = tilemap.tilemap.local_to_map(tilemap.tilemap.get_local_mouse_position())
	
	var input := {}
	if input_vector != Vector2i.ZERO:
		input["input_vector"] = input_vector
	if cast_spell:
		input["cast_spell"] = cast_spell
		input["click_position"] = clicked_cell
	if select_spell:
		input["select_spell"] = true
		input["spell_index"] = new_spell_slot
	return input

func _predict_remote_input(previous_input: Dictionary, _ticks_since_real_input: int) -> Dictionary:
	var input = previous_input.duplicate()
	input.erase("input_vector")
	input.erase("cast_spell")
	input.erase("spell_index")
	
	return {}

func _network_process(input: Dictionary) -> void:
	if can_move:
		var movement_vector : Vector2 = Vector2(input.get("input_vector", Vector2.ZERO) * 16)
		if movement_vector != Vector2.ZERO:
			can_move = false
			position += Vector2(input.get("input_vector", Vector2.ZERO) * 16)
			tile_position = tilemap.tilemap.local_to_map(global_position)
	
	if input.get("select_spell"):
		selected_spell_slot = input.get("spell_index")
	if input.get("cast_spell", false):
		var data = {}
		data['spellslot'] = self
		data['tile_position'] = tile_position
		data['click_position'] = input.get("click_position")
		SyncManager.spawn(spell_slots[selected_spell_slot].spell_resource.spell_name, $/root/Game, spell_slots[selected_spell_slot].spell_resource.spell_scene, data)
		#spell_slots[selected_spell_slot].button_pressed(tile_position, input.get("click_position"))
	
	set_visibility()

func _save_state() -> Dictionary:
	return {
		position = position,
		tile_position = tile_position,
		frame_1 = frame_1,
		selected_spell_slot = selected_spell_slot,
		can_move = can_move,
	}

func _load_state(state : Dictionary) -> void:
	position = state["position"]
	tile_position = state["tile_position"]
	frame_1 = state["frame_1"]
	selected_spell_slot = state["selected_spell_slot"]
	can_move = state["can_move"]

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
	var spell_resources : Array = character_sheet.get_spells()
	var i : int = 0
	
	for spell_slot in spell_slots:
		if i > spell_resources.size() or spell_resources[i] == null:
			continue
		spell_slot.setup_spell(spell_resources[i])
		spell_slot.parent_nodepath = get_path()
		tick_timer.timeout.connect(spell_slot.increment_ready)
		i+=1

func update_animation() -> void:
	if frame_1:
		sprite.region_rect.position.x = character_sheet.sprite_float_rect[character_sheet.character_index].position.x + character_sheet.sprite_size
		frame_1 = false
	else:
		sprite.region_rect.position.x = character_sheet.sprite_float_rect[character_sheet.character_index].position.x
		frame_1 = true
