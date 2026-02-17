extends Control

@export var spell_resource : SpellResource
@export var progress_bar : ProgressBar
@export var spell_sprite : Sprite2D

var spell_name : String
var current_ticks : int = 0
var spell_ready : bool = false

var active_spell : Node2D = null

func _ready() -> void:
	visible = false

func setup_spell(new_spell_resource : SpellResource) -> void:
	spell_resource = new_spell_resource
	visible = true
	spell_sprite.texture = spell_resource.spell_texture
	progress_bar.max_value = spell_resource.ticks_to_charge
	spell_sprite.position = size/2

func increment_ready() -> void:
	if spell_resource == null:
		return
	if spell_ready == true:
		return
	current_ticks += 1
	progress_bar.value = current_ticks
	if current_ticks == spell_resource.ticks_to_charge:
		spell_ready = true
		spawn_spell()

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
	
	active_spell = SyncManager.spawn("Spell", self, spell_resource.spell_scene)
	active_spell.spell_cast.connect(reset_spell_slot)
