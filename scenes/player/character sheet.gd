class_name CharacterSheet extends Resource

@export var character_name : String
@export var character_index : int
@export var spell_1 : PackedScene
@export var spell_2 : PackedScene
@export var spell_3 : PackedScene
@export var spell_4 : PackedScene

var sprite_sheet : Texture2D = preload("res://assets/tileset/Rogue Character Sheet.png")

const sprite_size : int = 14
const sprite_float_rect : Dictionary = {
	0 : Rect2(0 * sprite_size, 0 * sprite_size, sprite_size, sprite_size),
	1 : Rect2(2 * sprite_size, 0 * sprite_size, sprite_size, sprite_size),
	2 : Rect2(0 * sprite_size, 1 * sprite_size, sprite_size, sprite_size),
	3 : Rect2(2 * sprite_size, 1 * sprite_size, sprite_size, sprite_size),
}

func get_spells() -> Array:
	return [spell_1, spell_2, spell_3, spell_4]
