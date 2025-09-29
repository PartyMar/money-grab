extends Node


# signals
## Declare finish of run.
signal run_finished(victory: bool)
## Declare change in coin amount.
signal coin_added()

# in-run variables
var coins_count: int = 0
var coins_amount: int = 0
var player: Player


func add_coin(value: int) -> void:
	coins_count += 1
	coin_added.emit()
	
	# check victory condition
	if coins_count >= coins_amount:
		run_finished.emit(true)


func reset_variables() -> void:
	coins_count = 0
