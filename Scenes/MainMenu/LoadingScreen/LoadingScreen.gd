extends Control

signal loaded

var loading_path : String


func start_loading(path : String) -> void:
	loading_path = path

	ResourceLoader.load_threaded_request(loading_path)

func _process(_delta : float) -> void:
	if not loading_path or get_node("EmploymentContract").visible:
		return
	
	get_node("ProgressBar").visible = true
	
	var progress := []
	var status := ResourceLoader.load_threaded_get_status(loading_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		get_node("ProgressBar").value = progress[0]
		prints(progress[0])
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var loaded_resource := ResourceLoader.load_threaded_get(loading_path)
		loaded.emit(loaded_resource)

		prints("LOADED")
		loading_path = ""
	else:
		push_error("Couldn't load resource at ", loading_path)
	