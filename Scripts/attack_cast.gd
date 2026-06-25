extends RayCast3D
class_name AttackCast
@onready var initiator: Node =get_owner()

func _ready() -> void:
	randomize()

func deal_damage(damage:float) -> void:
	if not is_colliding():
		return
	var collider=get_collider()
	print(collider)
	if (collider is Enemy or collider is EnemyTree) and (initiator as Player):
		# 不再对击中的物体再次反应
		add_exception(collider)
		var critical_hit:float=randf()<initiator.MyStats.Agility.GetValue()
		if (initiator.IsAttacking and critical_hit) or initiator.IsHeavyAttacking:
			damage*=2
			VfxManger.spawn_damage_number(int(damage),Color.RED,get_collision_point())
		else:
			VfxManger.spawn_damage_number(int(damage),Color.WHITE,get_collision_point())
		collider.health_component.take_damage(damage)
	elif initiator is EnemyTree and initiator.check_state("AttackSpace") and collider is Player:
		add_exception(collider)
		VfxManger.spawn_damage_number(damage,Color.RED,get_collision_point())
		collider.health_component.take_damage(damage)
	
