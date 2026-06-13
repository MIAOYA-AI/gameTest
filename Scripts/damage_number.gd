extends Node3D
class_name damage_number
@onready var label_3d: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup_label(damage:int,color:Color,position_in:Vector3) -> void:
# 该方法会被全局调用 所以先检查是否已加载到了场景树中
	if not is_inside_tree():
		await ready
	
	label_3d.text=str(damage)
	label_3d.modulate=color
	global_position=position_in
