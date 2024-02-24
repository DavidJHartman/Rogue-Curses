extends Control

@onready var username_field := $"VBoxContainer/Personal Info Fields/GridContainer/Username Field"
@onready var password_field := $"VBoxContainer/Personal Info Fields/GridContainer/Password Field"
@onready var email_field := $"VBoxContainer/Personal Info Fields/GridContainer/Email Field"
@onready var screen_controller = $"%Online Menu"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_register_pressed():
	var username = username_field.text.strip_edges()
	var password = password_field.text.strip_edges()
	var email = email_field.text.strip_edges()
	
	var session = await Online.nakama_client.authenticate_email_async(email, password, username, true)
	
	if session.is_exception():
		print(session.get_exception().message)
	
	Online.nakama_session = session
	screen_controller.switch_screen("Find Match")


func _on_login_pressed():
	var username = username_field.text.strip_edges()
	var password = password_field.text.strip_edges()
	var email = email_field.text.strip_edges()
	
	var session = await Online.nakama_client.authenticate_email_async(email, password, null, false)
	
	if session.is_exception():
		print(session.get_exception().message)
	
	Online.nakama_session = session
	screen_controller.switch_screen("Find Match")
