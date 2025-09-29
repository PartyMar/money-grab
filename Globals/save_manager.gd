extends Node


const SAVE_PATH: String = "user://save_file.tres"

# for various purposes in future
signal saved

var save_data: SaveData
## Wacky boolean for checking should lvl_generator
## generate map or just load save version.
var save_loading: bool = false


func _ready() -> void:
	_load_save_file()


func save_game() -> void:
	var data: SaveData = SaveData.new()
	data.coins_count = GameManager.coins_count
	data.coins_amount = GameManager.coins_amount
	
	for node in get_tree().get_nodes_in_group("SaveObject"):
		var packed_node: PackedScene = PackedScene.new()
		packed_node.pack(node)
		data.saved_objects.append(packed_node)
	
	# set data for loading the save
	save_data = data
	ResourceSaver.save(data, SAVE_PATH)
	saved.emit()


func load_game() -> void:
	if save_data != null:
		save_loading = true
		SceneManager.load_scene("level1")


func _load_save_file() -> bool:
	if FileAccess.file_exists(SAVE_PATH) == false:
		return false
	
	save_data = ResourceLoader.load(SAVE_PATH)
	GameManager.coins_count = save_data.coins_count
	GameManager.coins_amount = save_data.coins_amount
	
	return true
