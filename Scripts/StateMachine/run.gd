extends StateBase

## 玩家节点
@export var player:Player
@onready var dash: Dash = $"../Dash"

func enter() -> void:
	super.enter()
	print("奔跑")
	player.PlayAnimation("Run",true)
	
func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	if player.velocity.y!=0:
		if player.velocity.y>0:
			state_machine.change_state("Jump")
		else:
			state_machine.change_state("Fall")
	elif player.IsDash:
		if dash.is_readly():
			state_machine.change_state("Dash")
		else:
			player.IsDash=false
	elif player.Direction==Vector3.ZERO:
		state_machine.change_state("Idle")
