extends Node2D

@export var ticks_alive : int = 10
@export var sprite : Sprite2D
var current_ticks : int = 0
var frame_1 : bool = true
var tile_position : Vector2i
@onready var game : Node2D = $"/root/Game"

func _ready() -> void:
	SyncManager.set_synced(self, "frame_1", frame_1)
	SyncManager.set_synced(self, "current_ticks", current_ticks)

func _network_spawn(data : Dictionary) -> void:
	$"/root/Game/NetworkTimer".timeout.connect(update_animation)
	$"/root/Game/NetworkTimer".timeout.connect(increment_ticks)
	global_position = data["position"] * 16 + Vector2(8, 8)
	tile_position = game.current_map.tilemap.local_to_map(global_position)
	
	for player in get_tree().get_nodes_in_group("players"):
		if player.tile_position == tile_position:
			player.decrement_health()
			player.lose_turn(-2)
			SyncManager.despawn(self)

func check_damage_players() -> void:
	for player in get_tree().get_nodes_in_group("players"):
		if (player.tile_position - tile_position) == Vector2i.ZERO:
			player.decrement_health()
			return

func _process(_delta : float) -> void:
	set_visibility()

func set_visibility() -> void:
	var my_peer_id : int
	if multiplayer.is_server(): my_peer_id = 1
	else: my_peer_id = multiplayer.get_unique_id()
	
	var space_state = get_world_2d().direct_space_state
	var position_to_check : Vector2 = Vector2.ZERO
	for _player in get_tree().get_nodes_in_group("players"):
		if _player.get_multiplayer_authority() == my_peer_id:
			position_to_check = _player.global_position
	
	var query = PhysicsRayQueryParameters2D.create(global_position, position_to_check)
	var result = space_state.intersect_ray(query)
	if result:
		visible = false
		return
	visible = true

func increment_ticks() -> void:
	check_damage_players()
	current_ticks += 1
	if ticks_alive == current_ticks:
		SyncManager.despawn(self)

func update_animation() -> void:
	if frame_1:
		sprite.region_rect.position.x += 16
		frame_1 = false
	else:
		sprite.region_rect.position.x -= 16
		frame_1 = true

func decrement_health() -> void:
	SyncManager.despawn(self)
