extends Control

@export var spell_resource : SpellResource
@export var progress_bar : ProgressBar
@export var spell_sprite : Sprite2D

var spell_name : String
var current_ticks : int = 0
var spell_ready : bool = false

var active_spell : Node2D = null

func _save_state() -> Dictionary:
	return{
		visible = visible,
		current_ticks = current_ticks,
		spell_ready = spell_ready,
		active_spell_path = str(active_spell.get_path()) if active_spell else ""
	}

func _load_state(state : Dictionary) -> void:
	visible = state['visible']
	current_ticks = state['current_ticks']
	spell_ready = state['spell_ready']
	if state['active_spell_path'] != "":
		active_spell = get_node(state['active_spell_path'])
	else:
		active_spell = null

func _ready() -> void:
	visible = false

func setup_spell(new_spell_resource : SpellResource) -> void:
	spell_resource = new_spell_resource
	visible = true
	spell_sprite.texture = spell_resource.spell_texture
	progress_bar.max_value = spell_resource.ticks_to_charge
	spell_sprite.position = size/2

func _network_process(_data : Dictionary) -> void:
	if spell_resource == null:
		return
	if active_spell != null:
		return
	if current_ticks == spell_resource.ticks_to_charge:
		spawn_spell()

func increment_ready() -> void:
	if spell_resource == null:
		return
	
	current_ticks += 1
	progress_bar.value = current_ticks

func reset_spell_slot() -> void:
	current_ticks = 0
	progress_bar.value = current_ticks
	spell_ready = false
	active_spell = null

func button_pressed(cast_position : Vector2, tile_position : Vector2) -> void:
	if active_spell == null:
		return
	active_spell.receive_input(cast_position, tile_position)

func spawn_spell() -> void:
	if spell_resource == null:
		return
	active_spell = SyncManager.spawn(spell_resource.spell_name, $/root/Game, spell_resource.spell_scene)
	active_spell.spell_cast.connect(reset_spell_slot)
