extends Control

@onready var find_match_header := $"VBoxContainer/Header/find_match_header"
@onready var find_match_button := $"VBoxContainer/MarginContainer/HBoxContainer/find match button"
@onready var screen_controller := $"%Online Menu"

# Called when the node enters the scene tree for the first time.
func _ready():
	OnlineMatch.connect("matchmaker_matched", on_match_found)
	OnlineMatch.min_players = 2
	OnlineMatch.max_players = 2
	OnlineMatch.client_version = 'dev'

func on_match_found(_players) -> void:
	screen_controller.switch_screen("Ready Screen")
	screen_controller.current_screen.initialize({players = _players})

func _on_button_pressed():
	find_match_button.visible = false
	find_match_header.visible = true
	
	if not Online.is_nakama_socket_connected():
		Online.connect_nakama_socket()
		await Online.socket_connected
	
	var data = {
		min_count = 2,
		max_count = 2
	}
	
	OnlineMatch.start_matchmaking(Online.nakama_socket, data)
