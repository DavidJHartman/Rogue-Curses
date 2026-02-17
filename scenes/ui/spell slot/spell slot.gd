extends Control

var spell : PackedScene
@export var progress_bar : ProgressBar
@export var spell_sprite : Sprite2D
var spell_name : String
var current_ticks : int = 0
var spell_ready : bool = false

var active_spell : Node2D = null

signal cast_spell

func _ready() -> void:
	if spell == null:
		return
	progress_bar.max_value = spell.ticks_to_charge
	spell_sprite.position = size/2

func increment_ready() -> void:
	if spell_ready == true:
		return
	current_ticks += 1
	progress_bar.value = current_ticks
	if current_ticks == spell.ticks_to_charge:
		spell_ready = true

func reset_spell_slot() -> void:
	current_ticks = 0
	progress_bar.value = current_ticks
	spell_ready = false

func button_pressed() -> void:
	pass
