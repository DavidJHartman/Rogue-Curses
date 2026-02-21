class_name RemoteVisibility extends Node2D

var my_player : Player

@onready var players : Array = get_tree().get_nodes_in_group("players")

func _process(_delta : float) -> void:
	for player in players:
		if player == my_player:
			continue
		if _check_line_of_site(player):
			player.line_of_site_entities[player] = true
		else:
			if player.line_of_site_entities.has(player):
				player.line_of_site_entities.erase(player)

func _check_line_of_site(player : Player) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	var result = space_state.intersect_ray(query)
	
	if result:
		return false
	
	return true

func clean_up_on_despawn() -> void:
	for player in players:
		if player.line_of_site_entities.has(player):
			player.line_of_site_entities.erase(player)
