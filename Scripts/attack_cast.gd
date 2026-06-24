extends RayCast3D
class_name AttackCast
@onready var player: Node =get_owner()

func _ready() -> void:
	randomize()

# player
func deal_damage(damage:float) -> void:
	if not is_colliding():
		return
	var collider=get_collider()
	print(collider)
	if collider is Enemy and (player as Player):
		# 不再对击中的物体再次反应
		add_exception(collider)
		var critical_hit:float=randf()<player.MyStats.Agility.GetValue()
		if (player.IsAttacking and critical_hit) or player.IsHeavyAttacking:
			damage*=2
			VfxManger.spawn_damage_number(int(damage),Color.RED,get_collision_point())
		else:
			VfxManger.spawn_damage_number(int(damage),Color.WHITE,get_collision_point())
		collider.health_component.take_damage(damage)
