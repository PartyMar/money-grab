class_name SaveData
extends Resource


## amount of coins requires.
@export var coins_amount: int = 0
## amount of coins already collected.
@export var coins_count: int = 0

## Objects to instantiate in scene, from Save group.
@export var saved_objects: Array[PackedScene] = []
