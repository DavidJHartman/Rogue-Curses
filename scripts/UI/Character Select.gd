extends Control

@onready var sprite := $"%Sprite"
@onready var animation_player := $"%CharacterSelectAnimation"

var current_character := ""
var character_index := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play(GameSetup.MY_CHARACTER_SHEET.character_name)
	sprite.modulate = GameSetup.MY_CHARACTER_SHEET.color
	character_index = GameSetup.character_names.find(GameSetup.MY_CHARACTER_SHEET.character_name, 0)
	current_character = GameSetup.MY_CHARACTER_SHEET.character_name
	$"%Character Name".text = "[center]" + current_character

func cycle_character(direction : int) -> void:
	character_index += direction
	if character_index < 0:
		character_index = GameSetup.character_names.size() - 1
	if character_index == GameSetup.character_names.size():
		character_index = 0
	
	GameSetup.MY_CHARACTER_SHEET.character_name = GameSetup.character_names[character_index]
	
	current_character = GameSetup.MY_CHARACTER_SHEET.character_name
	$"%Character Name".text = "[center]" + current_character
	animation_player.play(GameSetup.MY_CHARACTER_SHEET.character_name)

func update_color(color):
	GameSetup.MY_CHARACTER_SHEET.color = color
	sprite.modulate = GameSetup.MY_CHARACTER_SHEET.color

func _on_cycle_left_button_pressed():
	cycle_character(-1)

func _on_cycle_right_button_pressed():
	cycle_character(1)
