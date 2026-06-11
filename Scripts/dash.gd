extends StateBase
class_name Dash
@export var player:Player
@onready var timer: Timer = $Timer

var dath_duration=0.2
var time_remaining

func enter() -> void:
	timer.start()
	time_remaining=dath_duration
	super.enter()
	print("冲刺")
	
func exit() -> void:
	super.exit()
	
func physics_process_update(delta: float) -> void:
	if player.IsDash==false:
		state_machine.change_state("Idle")
	time_remaining-=delta
	if time_remaining <=0:
		print("No dashing")
	else:
		print("dashing")
	
func _on_blend_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Dodge_Forward":
		player.IsDash=false
		
func is_readly() -> bool:
	return timer.is_stopped()
