extends Spell

@export var speed : float = 1.0
@export var mine : PackedScene

@onready var game : Node2D = $"/root/Game"

var player : Player
var end_position : Vector2i
var direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	SyncManager.set_synced(self, "global_position", global_position)
	SyncManager.set_synced(self, "direction", direction)
	SyncManager.set_synced(self, "active", active)
	SyncManager.set_synced(self, "end_position", end_position)
	

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	direction = data['click_position'] - data['cast_position']
	player = get_node(data['caster'])
	end_position = data['click_position']
	global_position = (Vector2(data['cast_position'] * 16) + Vector2(8, 8)) + (direction.normalized() * 16)
	active = true
	
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
	spell_cast.emit.call_deferred()

func _process(_delta : float) -> void:
	set_visibility()

func _network_process(_input: Dictionary) -> void:
	if  game.current_map.query_location(global_position):
		SyncManager.despawn(self)
	
	var tilemap : LevelMap = player.tilemap
	if tilemap.tilemap.local_to_map(global_position) == end_position:
		var data : Dictionary = {
			"caster" = player.get_path(),
			"spellslot_path" = parent_nodepath,
			"cast_position" = end_position,
		}
		SyncManager.spawn("mine", $/root/Game/SubViewportContainer/SubViewport, mine, data)
		SyncManager.despawn(self)
		return
	
	global_position += direction.normalized() * speed
