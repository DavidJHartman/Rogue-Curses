extends Button

var button_text : String

# Called when the node enters the scene tree for the first time.
func _ready():
	button_text = text
	$"Button Text".text = button_text
	text = "              "


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	$"Button Text".text = "[center][wave]" + button_text

func _on_mouse_exited():
	$"Button Text".text = button_text
