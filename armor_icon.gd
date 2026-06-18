extends ItemIcon
class_name armor_icon

@export var power:int
@export var armor:armor_type

enum armor_type{
	IRON_PLATE,
	STEEL_PLATE
}

func _ready() -> void:
	num_label.text="+"+str(power)
	name_label.text=armor_type.keys()[armor]
	# 标准化字符串
	name_label.text=name_label.text.capitalize()
