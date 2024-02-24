extends HBoxContainer

var status : String = ""
var username : String = ""
var host := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize(_username : String, _status : String):
	set_username(_username)
	set_ready(status)

func set_ready(_user_ready) -> void:
	$"ready label".text = "[center][wave]"
	$"ready label".text += _user_ready
	status = _user_ready

func set_username(_current_username) -> void:
	$"username label".text = _current_username
	username = _current_username
	pass
