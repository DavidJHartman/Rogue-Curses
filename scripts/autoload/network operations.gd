extends Node

func change_scene(path, info):
	if not SyncManager.network_adaptor.is_network_host():
		return null
	
	print("Authority calling scene change")
	
	var full_info = {
		path = path,
		info = info
	}
	
	_op_change_scene.rpc(full_info)

@rpc("authority", "call_local", "reliable")
func _op_change_scene(full_info : Dictionary) -> void:
	print("Try remote scene change")
	var path = full_info["path"]
	var info = full_info["info"]
	if get_tree().change_scene_to_file(path) != OK:
		get_tree().quit(-1)
	_op_finish_change_scene.call_deferred(info)

func _op_finish_change_scene(info) -> void:
	print("Finish changing scene?")
	await get_tree().create_timer(2).timeout
	var scene = get_tree().get_current_scene()
	if scene.has_method("scene_setup"):
		scene.scene_setup(info)

