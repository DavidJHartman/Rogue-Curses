extends PanelContainer

@export var character_sheet_sprite : Sprite2D

var character_sheet_index : int = 0
var frame_1 : bool = true

func _ready() -> void:
	character_sheet_sprite.texture = Lobby.character_sheets[character_sheet_index].sprite_sheet
	character_sheet_sprite.region_rect = Lobby.character_sheets[character_sheet_index].sprite_float_rect[Lobby.character_sheets[character_sheet_index].character_index]

func update_animation() -> void:
	if frame_1:
		character_sheet_sprite.region_rect.position.x += Lobby.character_sheets[character_sheet_index].sprite_size
		frame_1 = false
	else:
		character_sheet_sprite.region_rect.position.x -= Lobby.character_sheets[character_sheet_index].sprite_size
		frame_1 = true


func _on_character_button_pressed(extra_arg_0: int) -> void:
	character_sheet_index = extra_arg_0
	frame_1 = true
	character_sheet_sprite.region_rect = Lobby.character_sheets[character_sheet_index].sprite_float_rect[Lobby.character_sheets[character_sheet_index].character_index]
	Lobby.player_info["class_index"] = character_sheet_index
