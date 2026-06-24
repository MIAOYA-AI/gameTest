extends StateBase

## 玩家节点
@export var player:Player
@export var hit_box_collision_shap:CollisionShape3D
@export var attack_animation:AnimationPlayer
@onready var attack_cast: AttackCast = %AttackCast
@onready var dash: Dash = $"../Dash"
@onready var animation_tree: AnimationTree = $"../../PlayerModel/BlendAnimationTree"
@onready var play_back: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback") if animation_tree else null

var player_speed:float
var _attack_frame_count:int = 0

func enter() -> void:
	super.enter()
	_attack_frame_count = 0
	print("攻击")
	## 攻击状态减慢玩家速度
	player_speed=player.Speed
	player.Speed*=0.005
	# 攻击动画 旧动画树
	#player.PlayAttackOneShot()
	# 单独的动画过程控制包围盒的开关与武器攻击特效 暂时屏蔽 使用RayCast3D方案
	if player.IsAttacking and not check_state("Attack") and play_back:
		attack_animation.play("attack")
		play_back.travel("Attack")
	elif player.IsHeavyAttacking and not check_state("HeavyAttack") and not check_state("HeavyAttackOver") and play_back:
		attack_animation.play("HeavyAttack")
		play_back.travel("HeavyAttack")
	
func check_state(state_name: String) -> bool:
	if play_back == null:
		return false
	return play_back.get_current_node() == state_name

func exit() -> void:
	super.exit()
	## 离开状态时恢复玩家速度
	player.Speed=player_speed
	player.IsAttacking=false
	player.IsHeavyAttacking=false
	attack_cast.clear_exceptions()

func physics_process_update(delta: float) -> void:
	super.physics_process_update(delta)
	if player.IsDash==true&&dash.is_readly():
		state_machine.change_state("Dash")
	else:
		player.IsDash=false
	attack_cast.deal_damage(player.MyStats.Strength.GetValue()+player.MyStats.WeaponDamage)
	
func hit_box_enable(state:bool) -> void:
	hit_box_collision_shap.disabled=!state
	
## 由AttackTime动画通知
func to_idle() -> void:
	state_machine.change_state("Idle")

# 重击通过动画结束信号检测
func _on_blend_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="1H_Melee_Attack_Stab" or anim_name=="2H_Melee_Attack_Stab":
		state_machine.change_state("Idle")
