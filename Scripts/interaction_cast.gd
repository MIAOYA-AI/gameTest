extends ShapeCast3D
class_name  interaction_cast

@export var ui:user_interface
# todo:解决打开界面后鼠标跳到屏幕中间视角会晃动与鼠标左键攻击依然生效
func check_interactions() -> void:
	# 如果有已经打开的物品窗口则先关闭
	if Input.is_action_just_pressed("interact") and ui.loot_container.visible:
		ui.loot_container.close()
	for collider_idx in get_collision_count():
		var collider=get_collider(collider_idx)
		if (collider as Chect):
			ui.show_interact_text("Open Chest")
			if Input.is_action_just_pressed("interact"):
				ui.loot_container.open(collider)
