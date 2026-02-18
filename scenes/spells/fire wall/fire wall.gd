extends Spell

@export var fire_effect : PackedScene

var start_position : Vector2i = Vector2.ZERO
var end_position : Vector2i = Vector2.ZERO

func _network_process(_input: Dictionary) -> void:
	if not active:
		return

func receive_input(_cast_position : Vector2, _tile_position : Vector2i) -> void:
	if not active:
		active = true
		start_position = _tile_position
	else:
		end_position = _tile_position
		spawn_fire()
		spell_cast.emit()
		SyncManager.despawn(self)

func spawn_fire() -> void:
	var x1 : int = end_position.x
	var y1 : int = end_position.y
	var x0 : int = start_position.x
	var y0 : int = start_position.y
	var points : Array = []
	
	var dx: int = abs(x1 - x0)
	var dy: int = abs(y1 - y0)
	
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	
	var err: int = dx - dy
	
	while true:
		SyncManager.spawn("Fire", $/root/Game, fire_effect, {"position" : Vector2(x0, y0)})
		
		if x0 == x1 and y0 == y1:
			break
		
		var e2: int = 2 * err
		
		if e2 > -dy:
			err -= dy
			x0 += sx
			
		if e2 < dx:
			err += dx
			y0 += sy

func _save_state() -> Dictionary:
	return {
		start_position = start_position,
		end_position = end_position
	}

func _load_state(state : Dictionary) -> void:
	start_position = state["start_position"]
	end_position = state["end_position"]
