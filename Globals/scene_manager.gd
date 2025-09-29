extends Node


# signal for declaring finish of loading and hiding loading screen
signal load_done
# signal for pausing and resuming game during level
signal pause_switched(paused: bool)

# game Scenes for loading voa res loader
var game_scenes = {
	"main_menu" = "res://Scenes/main_menu.tscn",
	"level1" = "res://Scenes/Levels/level1.tscn",
}

# vars for the rest of SM's functionality
var load_screen = load("res://Scenes/loading_screen.tscn")
var scene_path: String

var cursor_was_hidden: bool = false
var stick_was_unlocked: bool = false


#///# Node funcs #///#

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS


#///# Pause logic #///#

func switch_pause() -> void:
	get_tree().paused = !get_tree().paused
	pause_switched.emit(get_tree().paused)
	

#///# Loading scenes logci #///#

func load_scene(scene_id: String) -> void:
	if get_tree().paused == true:
		get_tree().paused = false
	
	scene_path = game_scenes[scene_id]
	if scene_path == "":
		push_error("wrong Scene ID!")
		return
	
	
	var load_screen_instance = load_screen.instantiate()
	
	get_tree().get_root().add_child(load_screen_instance, true)
	self.load_done.connect(load_screen_instance.start_outro)
	
	var loaded_resource: Resource = await CustomResLoader.load_res(scene_path)
	var new_scene = loaded_resource.instantiate()
	load_done.emit()
	
	get_tree().get_root().add_child(new_scene)
	if get_tree().current_scene: get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
