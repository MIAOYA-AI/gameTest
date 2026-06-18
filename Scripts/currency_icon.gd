extends ItemIcon
class_name currency_icon

@export var power:int

func _ready() -> void:
	num_label.text="+"+str(power)
