extends Node


@export var animator: AnimationPlayer


func start_outro() -> void:
	await get_tree().create_timer(0.5).timeout
	self.queue_free()
