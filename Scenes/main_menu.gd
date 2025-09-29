extends CanvasLayer


@export_category("Button nodes")
@export var button_new_run: Button
@export var button_load: Button
@export var button_quit: Button


func _init() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _ready() -> void:
	button_new_run.pressed.connect(press_new_run)
	button_load.pressed.connect(press_load)
	button_quit.pressed.connect(press_quit)
	
	button_new_run.grab_focus.call_deferred()
	
	# disable load button if there no save
	if SaveManager.save_data == null:
		button_load.disabled = true


## Start new game and load lvl1.
func press_new_run() -> void:
	SceneManager.load_scene("level1")


## Load game and load lvl1. 
func press_load() -> void:
	SaveManager.load_game()


## Closing game via button.
func press_quit() -> void:
	get_tree().quit()
