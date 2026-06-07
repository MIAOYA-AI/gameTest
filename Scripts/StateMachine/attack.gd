extends StateBase

## 玩家节点
@export var player:Player
@export var hit_box_collision_shap:CollisionShape3D
@export var attack_animation:AnimationPlayer

var player_speed:float
var _attack_frame_count:int = 0

func enter() -> void:
	super.enter()
	_attack_frame_count = 0
	print("攻击")
	## 攻击状态减慢玩家速度
	player_speed=player.Speed
	player.Speed*=0.005
	player.PlayAttackOneShot()
	attack_animation.play("attack")

func exit() -> void:
	super.exit()
	## 离开状态时恢复玩家速度
	player.Speed=player_speed
	player.IsAttacking=false

func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	
func hit_box_enable(state:bool) -> void:
	hit_box_collision_shap.disabled=state
	
## 由AttackTime动画通知
func to_idle() -> void:
	state_machine.change_state("Idle")
