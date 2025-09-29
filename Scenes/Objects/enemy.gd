class_name EnemyOne
extends StaticBody2D


@export_category("Nodes")
@export var attack_area: Area2D
@export var animator: AnimationPlayer
## Timer for behavior.
@export var timer: Timer

@export_category("Parameters")
## Enemy speed.
@export var speed: float = 100
## Delay for timer.
@export var act_delay: float = 1.5


# tween for moving
var tween: Tween


#///# Node funcs #///#
func _ready() -> void:
	timer.wait_time = act_delay
	# need to use that for loading save purpose (autostart does not work)
	timer.start()
	
	attack_area.body_entered.connect(player_touched)
	GameManager.run_finished.connect(game_finished)
	timer.timeout.connect(move)
	
	


func player_touched(body: Node2D) -> void:
	GameManager.run_finished.emit(false)


#///# Enemy special funcs #///#

func move() -> void:
	if tween != null:
		return
	
	var space_state = get_world_2d().direct_space_state
	var check_distance = 16.0
	var possible_directions = [
		Vector2(check_distance, 0),
		Vector2(-check_distance, 0),
		Vector2(0, check_distance),
		Vector2(0, -check_distance)
	]
	
	var available_directions: Array[Vector2] = []
	
	for direction in possible_directions:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = global_position + direction
		query.collision_mask = 1
		var result = space_state.intersect_point(query)
		
		if result.is_empty():
			available_directions.append(direction)
	
	if not available_directions.is_empty():
		var chosen_direction = available_directions[
			randi() % available_directions.size()
			]
		var duration: float = check_distance / speed
		tween = create_tween().bind_node(self)
		tween.tween_property(self, "position", position + chosen_direction, duration)
		await tween.finished
		tween = null


func game_finished(victory: bool) -> void:
	timer.stop()
	
	if victory == true:
		animator.play("Death")
