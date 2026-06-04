extends StateBase

## 玩家节点
@export var player:Player

func enter() -> void:
	super.enter()
	print("坠落")
	player.PlayAnimation("Jump_Land",true)
	
func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	if player.velocity.y==0:
		if player.Direction==Vector3.ZERO:
			state_machine.change_state("Idle")
		else:
			state_machine.change_state("Run")
	elif player.velocity.y>0:
		state_machine.change_state("Jump")
