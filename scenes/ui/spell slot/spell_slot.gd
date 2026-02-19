extends Panel

@export var progress_bar : ProgressBar
@export var spell_sprite : Sprite2D

var player_nodepath : NodePath
var spell_resource : SpellResource
var current_ticks : int = 0
var active_spell : Spell

signal receive_input(cast_position, tile_position)

func _ready() -> void:
	SyncManager.scene_spawned.connect(_on_SyncManager_scene_spawned)
	SyncManager.scene_despawned.connect(_on_SyncManager_scene_despawned)
	visible = false

func _network_process(_data : Dictionary) -> void:
	if spell_resource == null:
		return

func _save_state() -> Dictionary:
	return {
		current_ticks = current_ticks,
	}

func _load_state(state) -> void:
	current_ticks = state["current_ticks"]

func _on_SyncManager_scene_spawned(_scene_name, spawned_node, _scene, _data) -> void:
	if spawned_node is not Spell:
		return
	if spawned_node.player_nodepath == player_nodepath:
		spawned_node.spell_cast.connect(reset_spell_slot)
		receive_input.connect(spawned_node.receive_input)

func _on_SyncManager_scene_despawned(_scene_name, despawned_node) -> void:
	
	if despawned_node.player_nodepath == player_nodepath:
		despawned_node.spell_cast.disconnect(reset_spell_slot)
		receive_input.disconnect(despawned_node.receive_input)

func increment_ticks() -> void:
	current_ticks += 1
	progress_bar.value = current_ticks
	if current_ticks == spell_resource.ticks_to_charge:
		var spawned_node = SyncManager.spawn(spell_resource.spell_name, $"/root/Game", spell_resource.spell_scene, {"player_nodepath" : player_nodepath})
		spawned_node.spell_cast.connect(reset_spell_slot)
		receive_input.connect(spawned_node.receive_input)

func setup_spell(new_spell_resource : SpellResource) -> void:
	spell_resource = new_spell_resource
	visible = true
	spell_sprite.texture = spell_resource.spell_texture
	progress_bar.max_value = spell_resource.ticks_to_charge
	spell_sprite.position = size/2

func reset_spell_slot() -> void:
	current_ticks = 0
	progress_bar.value = current_ticks

func button_pressed(cast_position : Vector2, tile_position : Vector2) -> void:
	receive_input.emit(cast_position, tile_position)
