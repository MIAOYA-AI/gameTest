extends ShapeCast3D
class_name  interaction_cast

@export var ui:user_interface
@export var player:Player
# todo:解决打开界面后鼠标跳到屏幕中间视角会晃动与鼠标左键攻击依然生效
func check_interactions() -> void:
	var handled := false
	for collider_idx in get_collision_count():
		var collider=get_collider(collider_idx)
		if (collider as Chect):
			ui.show_interact_text("Open Chest")
			if Input.is_action_just_pressed("interact"):
				handled = true
				# 已经打开了物品窗口
				if ui.loot_container.visible:
					# 同一个箱子 → 关闭
					if collider == ui.loot_container.current_chect:
						ui.loot_container.close()
						return
					# 不同箱子 → 先关闭当前
					ui.loot_container.close()
				# 打开新箱子
				ui.loot_container.open(collider)
		elif(collider as Passage):
			ui.show_interact_text("Next Level")
			if Input.is_action_just_pressed("interact"):
				collider.travel(player)
	# 物品窗口可见但没瞄准任何箱子 → 按E关闭
	if not handled and Input.is_action_just_pressed("interact") and ui.loot_container.visible:
		ui.loot_container.close()
