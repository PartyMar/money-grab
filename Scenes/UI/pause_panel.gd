extends PanelContainer


@export_category("Button nodes")
@export var button_resume: Button
@export var button_new_run: Button
@export var button_load: Button
@export var button_save: Button
@export var button_quit: Button


func _ready() -> void:
	SceneManager.pause_switched.connect(switch_panel)
	SaveManager.saved.connect(enable_load_button, 4)


func switch_panel(paused: bool) -> void:
	if paused == true:
		show_panel()
	else:
		hide_panel()


func show_panel() -> void:
	self.visible = true
	
	# disable load button if there no save
	if SaveManager.save_data == null:
		button_load.disabled = true
	
	button_resume.grab_focus.call_deferred()


func hide_panel() -> void:
	self.visible = false


func enable_load_button() -> void:
	button_load.disabled = false
