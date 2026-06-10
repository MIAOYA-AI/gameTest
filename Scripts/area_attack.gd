extends ShapeCast3D
class_name area_attack

func deal_damage(damage:float) -> void:
	for collider_idx in get_collision_count():
		var collider=get_collider(collider_idx)
		if collider is Player or collider is Enemy:
			collider.health_component.take_damage(damage)
