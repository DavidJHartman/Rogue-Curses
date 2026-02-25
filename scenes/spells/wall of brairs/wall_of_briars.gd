extends Spell

@export var fire_effect : PackedScene
var tilemap : LevelMap

var start_position : Vector2i = Vector2.ZERO
var end_position : Vector2i = Vector2.ZERO

var x0 : int
var y0 : int
var x1 : int
var y1 : int

var dy : int
var dx : int

var sx : int
var sy : int

var err : int

func _ready() -> void:
	SyncManager.set_synced(self, "x0", x0)
	SyncManager.set_synced(self, "y0", y0)
	SyncManager.set_synced(self, "x1", x1)
	SyncManager.set_synced(self, "y1", y1)
	SyncManager.set_synced(self, "dx", dx)
	SyncManager.set_synced(self, "dy", dy)
	SyncManager.set_synced(self, "sx", sx)
	SyncManager.set_synced(self, "sy", sy)
	SyncManager.set_synced(self, "err", err)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	start_position = data["cast_position"]
	end_position = data["click_position"]
	
	var direction = Vector2(end_position - start_position).normalized()
	end_position = Vector2i(Vector2(start_position) + (direction * 50))
	
	x0 = start_position.x
	y0 = start_position.y
	x1 = end_position.x
	y1 = end_position.y
	
	dx = abs(x1 - x0)
	dy = abs(y1 - y0)
	
	sx = 1 if x0 < x1 else -1
	sy = 1 if y0 < y1 else -1
	
	err = dx - dy
	
	tilemap = get_node(data["caster"]).tilemap
	
	spell_cast.connect(get_node(parent_nodepath).reset_spell_slot)
	$"/root/Game/NetworkTimer".timeout.connect(increment_ticks)
	spawn_briar()
	spell_cast.emit.call_deferred()

func increment_ticks() -> void:
	spawn_briar()

func spawn_briar() -> void:
	if x0 == x1 and y0 == y1 or tilemap.query_location(Vector2i(x0, y0)):
		SyncManager.despawn(self)
	
	var e2: int = 2 * err
	
	if e2 > -dy:
		err -= dy
		x0 += sx
		
	if e2 < dx:
		err += dx
		y0 += sy
	SyncManager.spawn("Briar", $/root/Game/SubViewportContainer/SubViewport, fire_effect, {"position" : Vector2(x0, y0)})
