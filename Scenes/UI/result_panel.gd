extends PanelContainer


@export_category("Nodes")
@export var result_label: Label
@export var button_new_run: Button
@export var button_quit: Button
@export var sound_victory: AudioStreamPlayer
@export var sound_defeat: AudioStreamPlayer

@export var victory_message: String = "VICTORY"
@export var defeat_message: String = "GAME OVER"


func _ready() -> void:
	self.visible = false
	GameManager.run_finished.connect(show_result)


## Adjust visuals for result screen.
func show_result(victory: bool) -> void:
	if victory == true:
		result_label.text = victory_message
		sound_victory. play()
	else:
		result_label.text = defeat_message
		sound_defeat.play()
	
	self.visible = true
	button_new_run.grab_focus.call_deferred()
