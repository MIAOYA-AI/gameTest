extends RayCast3D

func deal_damage() -> void:
	if not is_colliding():
		return
	var collider=get_collider()
	print(collider)
	# 不再对击中的物体再次反应
	if collider is Enemy:
		collider.health_component.take_damage(100)
		add_exception(collider)
	
