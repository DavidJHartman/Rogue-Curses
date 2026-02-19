extends Spell

@export var speed : float = 1.0
@export var ticks_to_charge : int = 3
@export var collider : Area2D

@onready var game : Node2D = $"/root/Game"

var direction : Vector2 = Vector2.ZERO
var despawn : bool = false

func _ready() -> void:
	SyncManager.scene_despawned.connect(_on_SyncManager_scene_despawned)
	SyncManager.scene_spawned.connect(_on_SyncManager_scene_spawned)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	direction = Vector2i(data['tile_position']) - Vector2i(data['cast_position']/16)
	global_position = Vector2(data['cast_position']) + (direction)
	spell_cast.emit.call_deferred()

func _network_process(_input: Dictionary) -> void:
	if game.current_map.query_location(global_position):
		SyncManager.despawn(self)
		return
	
	global_position += direction.normalized() * speed

func _on_SyncManager_scene_spawned(_name, spawned_node, _scene, _data) -> void:
	if spawned_node == self:
		spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)

func _on_SyncManager_scene_despawned(_name, spawned_node) -> void:
	if spawned_node == self:
		spell_cast.disconnect(get_node(parent_nodepath).reset_spell_slot)

func _save_state() -> Dictionary:
	return {
		global_position = global_position,
		direction = direction
	}

func _load_state(state : Dictionary) -> void:
	global_position = state['global_position']
	direction = state['direction']
