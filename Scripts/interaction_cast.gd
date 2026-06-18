extends ShapeCast3D
class_name  interaction_cast

signal check_interactions_on(text)

func check_interactions() -> void:
	for collider_idx in get_collision_count():
		var collider=get_collider(collider_idx)
		if (collider as loot_container):
			check_interactions_on.emit("Open Chest")
			if Input.is_action_just_pressed("interact"):
				print(collider.get_items())
