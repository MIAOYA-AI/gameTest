extends StateBase
class_name Dash
@export var player:Player
@onready var timer: Timer = $Timer
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var dath_duration=0.2
var time_remaining

func enter() -> void:
	timer.start()
	gpu_particles_3d.emitting=true
	time_remaining=dath_duration
	super.enter()
	print("冲刺")
	
func exit() -> void:
	gpu_particles_3d.emitting=false
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
