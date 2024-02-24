extends Node

@onready var turn_timer = $"Network Timer"
@onready var player_hud = $"../Player HUD"

# Called when the node enters the scene tree for the first time.
func _network_spawn(data: Dictionary):
	turn_timer.start()
	player_hud.turn_timer = self


func get_progress() -> float:
	return (float(turn_timer.wait_ticks - turn_timer.ticks_left) / float(turn_timer.wait_ticks)) * 100
