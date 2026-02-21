extends Spell

@export var fire_effect : PackedScene

var start_position : Vector2i = Vector2.ZERO
var end_position : Vector2i = Vector2.ZERO

func _load_state(state : Dictionary) -> void:
	start_position = state["start_position"]
	end_position = state["end_position"]
func _ready() -> void:
	SyncManager.set_synced(self, "start_position", start_position)
	SyncManager.set_synced(self, "end_position", end_position)

func _network_spawn(data : Dictionary) -> void:
	parent_nodepath = data["spellslot_path"]
	start_position = data["click_position"]

func receive_input(data : Dictionary) -> void:
	end_position = data["click_position"]
	spawn_fire()
	spell_cast.emit()
	SyncManager.despawn(self)

func spawn_fire() -> void:
	var x1 : int = end_position.x
	var y1 : int = end_position.y
	var x0 : int = start_position.x
	var y0 : int = start_position.y
	
	var dx: int = abs(x1 - x0)
	var dy: int = abs(y1 - y0)
	
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	
	var err: int = dx - dy
	
	while true:
		SyncManager.spawn("Fire", $/root/Game/SubViewportContainer/SubViewport, fire_effect, {"position" : Vector2(x0, y0)})
		
		if x0 == x1 and y0 == y1:
			break
		
		var e2: int = 2 * err
		
		if e2 > -dy:
			err -= dy
			x0 += sx
			
		if e2 < dx:
			err += dx
			y0 += sy
