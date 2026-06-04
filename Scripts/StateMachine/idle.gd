extends StateBase

## 玩家节点
@export var player:Player

func enter() -> void:
	super.enter()
	print("闲置")
	player.PlayAnimation("Idle",true)
	
func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	if player.velocity.y!=0:
		if player.velocity.y>0:
			state_machine.change_state("Jump")
		else:
			state_machine.change_state("Fall")
	elif player.IsAttacking:
		state_machine.change_state("Attack")
	elif player.Direction!=Vector3.ZERO:
		state_machine.change_state("Run")
