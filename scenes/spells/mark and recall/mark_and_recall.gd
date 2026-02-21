extends Spell
@onready var game : Node2D = $"/root/Game"

var player : Player

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)

func _network_spawn(data : Dictionary) -> void:
	player = get_node(data["caster"])
	parent_nodepath = data["spellslot_path"]
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8))
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)

func _process(_delta : float) -> void:
	set_visibility()

func receive_input(_data : Dictionary) -> void:
	player.global_position = global_position
	spell_cast.emit()
	SyncManager.despawn(self)
