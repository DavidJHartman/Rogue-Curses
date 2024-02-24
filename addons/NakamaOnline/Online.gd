extends Node

# For developers to set from the outside, for example:
#   Online.nakama_host = 'nakama.example.com'
#   Online.nakama_scheme = 'https'
var nakama_server_key: String = 'defaultkey'
var nakama_host: String = '127.0.0.1'
var nakama_port: int = 7350
var nakama_scheme: String = 'http'

# For other scripts to access:
var nakama_client: NakamaClient :
	set(value):
		nakama_client = value
	get:
		if nakama_client == null:
			nakama_client = Nakama.create_client(
				nakama_server_key,
				nakama_host,
				nakama_port,
				nakama_scheme,
				Nakama.DEFAULT_TIMEOUT,
				NakamaLogger.LOG_LEVEL.ERROR)
		
		return nakama_client

var nakama_session: NakamaSession :
	set(value):# Close out the old socket.
		if nakama_socket:
			nakama_socket.close()
			nakama_socket = null
		
		nakama_session = value
		
		emit_signal("session_changed", nakama_session)
		
		if nakama_session and not nakama_session.is_exception() and not nakama_session.is_expired():
			emit_signal("session_connected", nakama_session)

var nakama_socket: NakamaSocket

# Internal variable for initializing the socket.
var _nakama_socket_connecting := false

signal session_changed (nakama_session)
signal session_connected (nakama_session)
signal socket_connected (nakama_socket)

func _set_readonly_variable(_value) -> void:
	pass

func _ready() -> void:
	# Don't stop processing messages from Nakama when the game is paused.
	Nakama.process_mode = PROCESS_MODE_ALWAYS


func connect_nakama_socket() -> void:
	if nakama_socket != null:
		return
	if _nakama_socket_connecting:
		return
	_nakama_socket_connecting = true
	
	var new_socket = Nakama.create_socket_from(nakama_client)
	await new_socket.connect_async(nakama_session)
	nakama_socket = new_socket
	_nakama_socket_connecting = false
	
	emit_signal("socket_connected", nakama_socket)

func is_nakama_socket_connected() -> bool:
	return nakama_socket != null && nakama_socket.is_connected_to_host()
