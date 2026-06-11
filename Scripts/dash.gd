extends StateBase

@export var player:Player

func enter() -> void:
	super.enter()
	print("冲刺")
	
func exit() -> void:
	super.exit()
	player.IsDash=false
	if player.Direction==Vector3.ZERO:
		state_machine.change_state("Idle")
	else:
		state_machine.change_state("Run")
	
func _on_blend_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Dodge_Forward":
		exit()
