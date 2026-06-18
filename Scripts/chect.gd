extends StaticBody3D
class_name chect

func get_items() -> Array:
	return get_children().filter(
		func(child): return child is ItemIcon
	)

func _ready() -> void:
	print(get_items())
