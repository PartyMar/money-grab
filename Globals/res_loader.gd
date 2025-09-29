extends Node


## Loading resource via ResourceLoader request.
func load_res(res_path: String, sub_thread: bool = true) -> Resource:
	var error = ResourceLoader.load_threaded_request(
		res_path, "", sub_thread, ResourceLoader.CACHE_MODE_IGNORE
		)
	if error != OK:
		push_error("Failed to start threaded load for %s: %s" % [res_path, error])
		return null
	
	var res: Resource = await _check_load_status(res_path)
	return res


func _check_load_status(res_path: String) -> Resource:
	var progress = [0.0]
	while true:
		var status = ResourceLoader.load_threaded_get_status(res_path, progress)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await get_tree().create_timer(0.1).timeout
			ResourceLoader.THREAD_LOAD_LOADED:
				var res = ResourceLoader.load_threaded_get(res_path)
				if res is Resource:
					return res
				else:
					push_error("Loaded resource is not a valid Resource for %s" % res_path)
					return null
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Threaded load failed for %s" % res_path)
				return null
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Invalid resource for %s" % res_path)
				return null
	return null
