extends Node

var character_names := ["G'lorbalorb", "Grinney", "Weebil", "Boo"]

var character_profile := "user://profile"
var MY_CHARACTER_SHEET

# Called when the node enters the scene tree for the first time.
func _ready():
	if not DirAccess.dir_exists_absolute("user://profile"):
		var dir = DirAccess.open("user://")
		dir.make_dir("profile")
	if not ResourceLoader.exists("user://profile/character_sheet.tres"):
		MY_CHARACTER_SHEET = ResourceLoader.load("res://resources/character_sheet.tres")
		var result = ResourceSaver.save(MY_CHARACTER_SHEET, "user://profile/character_sheet.tres")
	else:
		MY_CHARACTER_SHEET = ResourceLoader.load("user://profile/character_sheet.tres")

func save_character_sheet():
	var result = ResourceSaver.save(MY_CHARACTER_SHEET, "user://profile/character_sheet.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
