extends Control


signal player_ready()

@onready var online_menu := $"../../../"

#const LOG_FILE_DIRECTORY = "user://logs"

# Called when the node enters the scene tree for the first time.
func _ready():
	OnlineMatch.connect("player_joined", player_joined)
	OnlineMatch.connect("player_left", player_left)
	OnlineMatch.connect("player_status_changed", player_status_changed)
	OnlineMatch.connect("match_ready", match_ready)
	OnlineMatch.connect("match_not_ready", match_not_ready)

var user_ready = preload("res://scenes/Main Menu/username ready up.tscn")

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize(info : Dictionary):
	var players : Dictionary = info.get("players", {})
	var match_id : String = info.get("match_id", "")
	var clear : bool = info.get("clear", false)
	
	for session_id in players:
		var player = players[session_id]
		add_player(session_id, player.username, player.peer_id)

func _send_character_sheet():
	var buffer := StreamPeerBuffer.new()
	var name_index := GameSetup.character_names.find(GameSetup.MY_CHARACTER_SHEET.character_name, 0)
	var color := Vector4.ONE
	color.x = GameSetup.MY_CHARACTER_SHEET.color.r
	color.y = GameSetup.MY_CHARACTER_SHEET.color.g
	color.z = GameSetup.MY_CHARACTER_SHEET.color.b
	
	var character_sheet = {}
	character_sheet["character_name"] = GameSetup.MY_CHARACTER_SHEET.character_name
	character_sheet["color"] = GameSetup.MY_CHARACTER_SHEET.color
	print(SyncManager.network_adaptor.get_unique_id())
	print(OnlineMatch.get_session_id(SyncManager.network_adaptor.get_unique_id()))
	online_menu.player_character_sheets[SyncManager.network_adaptor.get_unique_id()] = character_sheet
	
	buffer.put_8(name_index)
	buffer.put_float(color.x)
	buffer.put_float(color.y)
	buffer.put_float(color.z)
	load_character_sheet.rpc(SyncManager.network_adaptor.get_unique_id(), buffer.data_array)

func add_player(session_id : String, username : String, player_id : int) -> void:
	if not $"%User List".has_node(session_id):
		var status = user_ready.instantiate()
		$"%User List".add_child(status)
		status.initialize(username, "Connecting...")
		status.name = session_id
		status.host = true if player_id == 1 else false


func remove_player(session_id: String) -> void:
	var status = $"%User List".get_node(session_id)
	if status:
		status.queue_free()

func _on_ready_up_pressed():
	_send_character_sheet()
	pass

func set_ready_status(session_id : String, status : String) -> void:
	var status_object = $"%User List".get_node_or_null(session_id)
	if status_object:
		status_object.set_ready(status)

func get_ready_status(session_id : String) -> String:
	var status = $"%User List".find_child(session_id)
	if status:
		return status.status
	return ""

@rpc("any_peer", "reliable")
func load_character_sheet(player_id : int, character_data : PackedByteArray) -> void:
	
	print("We RPCd!")
	
	var buffer = StreamPeerBuffer.new()
	buffer.put_data(character_data)
	buffer.seek(0)
	
	var character_name = GameSetup.character_names[buffer.get_8()]
	var character_color = Color(buffer.get_float(), buffer.get_float(), buffer.get_float())
	
	var new_character = {}
	new_character["character_name"] = character_name
	new_character["color"] = character_color
	
	online_menu.player_character_sheets[player_id] = new_character

func player_joined(player) -> void:
	add_player(player.session_id, player.username, player.peer_id)

func player_left(player) -> void:
	remove_player(player.session_id)

func player_status_changed(player, status) -> void:
	if status == OnlineMatch.PlayerStatus.CONNECTED:
		if get_ready_status(player.session_id) != "Ready!":
			set_ready_status(player.session_id, "Connected")
		if player.peer_id != SyncManager.network_adaptor.get_unique_id():
			SyncManager.add_peer(player.peer_id)
	elif status == OnlineMatch.PlayerStatus.CONNECTING:
		set_ready_status(player.session_id, "Connecting")

func match_ready(players) -> void:
	pass

func match_not_ready() -> void:
	pass
