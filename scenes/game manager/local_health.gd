extends ProgressBar
@export var game : Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = game.local_player.health
