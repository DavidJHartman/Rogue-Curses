extends Button

@onready var character_menu := $"../../.."
@export var color : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pressed", _on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	character_menu.update_color(color)
