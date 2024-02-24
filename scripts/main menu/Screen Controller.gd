extends Control

var current_screen = null

func _ready():
	for child in get_children():
		child.visible = false
	$Panel.visible = true
	$Login.visible = true
	current_screen = $Login

func switch_screen(screen_name : String) -> void:
	if current_screen != null:
		current_screen.visible = false
	
	current_screen = find_child(screen_name, false)
	current_screen.visible = true
	$Panel.visible = true

func remove_screen() -> void:
	if current_screen != null:
		current_screen.visible = false
		current_screen = null
	$Panel.visible = false
