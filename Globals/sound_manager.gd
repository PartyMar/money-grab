extends Node


# main player for music, barebone
var player: AudioStreamPlayer


func _ready() -> void:
	# ignore pause stuff
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load("res://Assets/sounds/music/time_for_adventure.mp3")
	player.volume_db = -10
	player.play()
