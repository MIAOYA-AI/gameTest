extends Node3D

const DAMAGE_NUMBER = preload("uid://c2ywxy454yhl4")

func spawn_damage_number(damage:int,color:Color,position_in:Vector3) -> void:
	var new_number_label:damage_number=DAMAGE_NUMBER.instantiate()
	new_number_label.setup_label(damage,color,position_in)
	add_child(new_number_label)
