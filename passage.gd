extends StaticBody3D
class_name Passage

@export_file("*.tscn") var next_level

func travel(player:Player) -> void:
	get_tree().reload_current_scene()
