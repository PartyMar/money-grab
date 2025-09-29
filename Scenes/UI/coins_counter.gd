extends HBoxContainer


@export var label: Label

## variable for adjusting left side of 
## label by num of digits on the right side.
var amount_length: int = 1


func _ready() -> void:
	# determine num of digits in right side of label
	amount_length = str(GameManager.coins_amount).length()

	adjust_label()
	
	# connect to the coin signal at the end of frame
	GameManager.coin_added.connect(adjust_label, 1)


## Adjusting indicator value to latest coin count.
func adjust_label() -> void:
	var left_side: String = str(GameManager.coins_count)
	# add zeros for matching num of digits to the right
	left_side = left_side.lpad(amount_length, "0")
	
	var right_side: String = str(GameManager.coins_amount)
	
	label.text = left_side + "/" + right_side
