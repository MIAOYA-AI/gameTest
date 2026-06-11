extends StateBase
class_name Dash
@export var player:Player
@onready var timer: Timer = $Timer

func enter() -> void:
	timer.start()
	super.enter()
	print("冲刺")
	
func exit() -> void:
	super.exit()
	
func physics_process_update(delta: float) -> void:
	if player.IsDash==false:
		state_machine.change_state("Idle")
	
func _on_blend_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Dodge_Forward":
		player.IsDash=false
		
func is_readly() -> bool:
	return timer.is_stopped()
