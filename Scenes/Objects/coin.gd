class_name Coin
extends Area2D


@export var coin_sound: AudioStreamPlayer


func _ready() -> void:
	body_entered.connect(coin_collected)


## One time trigger for ollecting coin.
func coin_collected(body: Node2D) -> void:
	# trigger signal for collecting coin in global
	GameManager.add_coin(1)
	
	# hide coin
	self.visible = false
	
	# play sound and await signal for finishing
	coin_sound.play()
	await coin_sound.finished
	
	# remove object from the scene
	self.queue_free()
