extends ItemIcon
class_name shield_icon

@export var protection:int
@export var item_model:PackedScene

func _ready() -> void:
	num_label.text="+"+str(protection)
	name_label.text=item_model.resource_path.get_file().rstrip('.'+item_model.resource_path.get_file().get_extension())
	# 标准化字符串
	name_label.text=name_label.text.capitalize()
