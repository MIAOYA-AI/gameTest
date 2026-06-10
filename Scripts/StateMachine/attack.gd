extends StateBase

## 玩家节点
@export var player:Player
@export var hit_box_collision_shap:CollisionShape3D
@export var attack_animation:AnimationPlayer
@onready var attack_cast: RayCast3D = %AttackCast

var player_speed:float
var _attack_frame_count:int = 0

func enter() -> void:
	super.enter()
	_attack_frame_count = 0
	print("攻击")
	## 攻击状态减慢玩家速度
	player_speed=player.Speed
	player.Speed*=0.005
	# 攻击动画
	player.PlayAttackOneShot()
	# 单独的动画过程控制包围盒的开关与武器攻击特效 暂时屏蔽 使用RayCast3D方案
	attack_animation.play("attack")
	

func exit() -> void:
	super.exit()
	## 离开状态时恢复玩家速度
	player.Speed=player_speed
	player.IsAttacking=false
	attack_cast.clear_exceptions()

func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	attack_cast.deal_damage()
	
func hit_box_enable(state:bool) -> void:
	hit_box_collision_shap.disabled=!state
	
## 由AttackTime动画通知
func to_idle() -> void:
	state_machine.change_state("Idle")
