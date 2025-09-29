extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CallMenu"):
		SceneManager.switch_pause()


#///# Button press signal funcs #///#

func press_resume() -> void:
	SceneManager.switch_pause()


func press_new_run() -> void:
	GameManager.reset_variables()
	SceneManager.load_scene("level1")


func press_load_game() -> void:
	SaveManager.load_game()


func press_save_game() -> void:
	SaveManager.save_game()


func press_quit() -> void:
	get_tree().quit()
