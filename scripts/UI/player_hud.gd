extends Node2D

var turn_timer
var my_player
@onready var progress_bar = $"CanvasLayer/MarginContainer/HBoxContainer/ProgressBar"
@onready var move_label = $"CanvasLayer/MarginContainer/HBoxContainer/RichTextLabel"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if turn_timer:
		var turn_timer_progress = turn_timer.get_progress()
		progress_bar.value = turn_timer_progress

func move_label_visible(is_visible : bool):
	move_label.visible = is_visible
