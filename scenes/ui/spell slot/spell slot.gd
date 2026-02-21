extends Control

@export var spell_resource : SpellResource
@export var progress_bar : ProgressBar
@export var spell_sprite : Sprite2D

var parent_nodepath : NodePath
var spell_name : String
var current_ticks : int = 0
var spell_ready : bool = false

var active_spell_path : NodePath = NodePath("")

func _ready() -> void:
	SyncManager.set_synced(self, "active_spell_path", active_spell_path)
	SyncManager.set_synced(self, "current_ticks", current_ticks)
	SyncManager.set_synced(self, "visible", visible)
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
	current_ticks += 1
	progress_bar.value = current_ticks

func reset_spell_slot() -> void:
	current_ticks = 0
	progress_bar.value = current_ticks
	active_spell_path = NodePath("")

func button_pressed(data) -> void:
	if current_ticks >= spell_resource.ticks_to_charge and active_spell_path == NodePath(""):
		spawn_spell(data)
	elif active_spell_path != NodePath("") :
		get_node(active_spell_path).receive_input(data)
	

func spawn_spell(data : Dictionary) -> void:
	if spell_resource == null:
		return
	data['spellslot'] = self
	active_spell_path = SyncManager.spawn(spell_resource.spell_name, $"/root/Game/".sub_viewport, spell_resource.spell_scene, data).get_path()
