extends ProgressBar
@export var timer : NetworkTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	value = timer.wait_ticks - timer.ticks_left
