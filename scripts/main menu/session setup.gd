extends Node2D

var player_list := {}
var player_character_sheets := {}

const LOG_FILE_DIRECTORY = "user://detailed_logs"
# Called when the node enters the scene tree for the first time.
func _ready():
	SyncManager.connect("sync_started", start_logging)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_logging():
	if not SyncReplay.active:
		var dir = DirAccess.open(LOG_FILE_DIRECTORY)
		if not dir:
			dir = DirAccess.open("user://")
			dir.make_dir_absolute(LOG_FILE_DIRECTORY)
			dir = DirAccess.open(LOG_FILE_DIRECTORY)
		
		var datetime = Time.get_datetime_dict_from_system(true)
		var match_id = OnlineMatch.match_id
		match_id.erase(match_id.length() - 1, 1)
		
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-%s-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			match_id,
			SyncManager.network_adaptor.get_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)

@rpc("any_peer", "call_local", "reliable")
func player_is_ready(id : String) -> void:
	$"%Ready Screen".set_ready_status(id, "Ready!")
	player_list[id] = true
	if multiplayer.is_server():
		print("I am server and this is player list: ", player_list)
		if player_list.size() == OnlineMatch.players.size():
			SyncManager.start()
			await SyncManager.sync_started
			print("Peer ID: ", id)
			load_match()

func load_match() -> void:
	var match_info = {}
	match_info["Map Name"] = "The Fortress.tscn"
	match_info["Players"] = OnlineMatch.get_player_names_by_peer_id()
	match_info["Character Sheets"] = player_character_sheets
	NetworkOperations.change_scene("res://scenes/game state/match.tscn", match_info)

func _on_ready_up_pressed():
	player_is_ready.rpc(OnlineMatch.my_session_id)
