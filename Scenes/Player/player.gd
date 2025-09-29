class_name Player
extends CharacterBody2D


## Enum of player character states: LOCKED, IDLE, RUN, ROLL.
enum States {
	LOCKED,
	IDLE,
	RUN,
	ROLL,
}


@export_category("Nodes")
@export var sprite: Sprite2D
@export var animator: AnimationPlayer

@export_category("Parameters")
## Base speed multiplier.
var speed_basic: float = 100
## Roll speed (that speed added to basic during roll).
var speed_roll: float = 75

## Determine wich player have control or not.
var active: bool = true
## player unit state.
var state_current: States
## Facing vector of character.
var face_direction: Vector2


#///# Node funcs #///#

func _ready() -> void:
	GameManager.player = self
	GameManager.run_finished.connect(on_run_finished)


func _physics_process(delta: float) -> void:
	get_input()
	
	match state_current:
		States.RUN:
			velocity = face_direction * speed_basic
		States.ROLL:
			velocity = face_direction * (speed_basic + speed_roll)
		_:
			velocity = Vector2.ZERO
	
	move_and_slide()


func _exit_tree() -> void:
	GameManager.player = null


#///# Player character custom funcs #///#

func get_input() -> void:
	if active == false: return
	
	# Check if player pressed roll and act accordingly
	if Input.is_action_pressed("Roll"):
		animator.play("Roll")
		active = false
		state_current = States.ROLL
		return
	
	# Get inputs from player and add velocity in that vector
	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	
	# Check if player press moving buttons and act accordingly
	if direction == Vector2.ZERO:
		enter_idle_state()
	else:
		face_direction = direction
		enter_run_state()


func roll_ended() -> void:
	if state_current == States.ROLL:
		state_current = States.IDLE
		active = true


## On run finishing logic.
func on_run_finished(victory: bool) -> void:
	active = false
	enter_idle_state()
	
	if victory == false:
		state_current = States.LOCKED
		animator.play("Death")
	#TODO add something like victory roll.


func enter_idle_state() -> void:
	state_current = States.IDLE
	animator.play("Idle")
	# set face direction horizontally
	var x_direction: float = -1.0 if sprite.flip_h == true else 1.0
	face_direction = Vector2(x_direction, 0)


func enter_run_state() -> void:
	state_current = States.RUN
	animator.play("Run")
	# adjust sprite for visual purpose
	if abs(face_direction.x) > 0:
		var face_side: float = signf(face_direction.x)
		sprite.flip_h = face_side < 1.0
