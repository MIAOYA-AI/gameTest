extends Node3D
# 与StateMachine功能冲突 用来测试其他的动画控制方式
# 该类主要控制玩家的行为动画与配合动画的位移
@onready var animation_tree: AnimationTree = $"../BlendAnimationTree"
@onready var play_back:AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@export var player:Player
@onready var health_component: HealthComponent = $"../../HealthComponent"
@onready var collision_shape_3d: CollisionShape3D = $"../../CollisionShape3D"
@onready var state_machine: StateMachine = $"../../StateMachine"
@onready var dash: Dash = $"../../StateMachine/Dash"

@export var animation_speed:float=10.0
@export var attack_move_distance:float=1.5

var run_path:String = "parameters/MoveSpace/blend_position"
var run_weight_target:=-1.0


func _ready() -> void:
	health_component.update_max_health(100)

func _physics_process(delta: float) -> void:
	# 移动
	update_animation_tree(player.Direction)
	animation_tree[run_path]=move_toward(
		animation_tree[run_path],
		run_weight_target,
		animation_speed*delta
	)
	# 攻击
	if player.IsAttacking==true&&!check_state("Attack"):
		play_back.travel("Attack")
	
	if player.IsHeavyAttacking==true&&!check_state("HeavyAttack")&&!check_state("HeavyAttackOver"):
		play_back.travel("HeavyAttack")
		
	if player.IsDash==true&&!check_state("Dash")&&dash.is_readly():
		play_back.travel("Dash")
		
	handle_slashing_physics_frame(delta)
	
func _on_health_component_defeat() -> void:
	play_back.travel("Defeat")
	set_physics_process(false)

func update_animation_tree(diretion:Vector3) ->void:
	if diretion.is_zero_approx():
		run_weight_target=-1.0
	else:
		run_weight_target=1.0
		
func check_state(state_name:String) -> bool:
	return play_back.get_current_node()==state_name
	
func handle_slashing_physics_frame(delta:float) -> void:
	if !(check_state("Attack")||check_state("Dash")):
		return
	if check_state("Attack"):
		player.velocity.x=player.CurDirection.x*attack_move_distance
		player.velocity.z=player.CurDirection.z*attack_move_distance
	if check_state("Dash"):
		player.velocity.x=player.CurDirection.x*attack_move_distance*5
		player.velocity.z=player.CurDirection.z*attack_move_distance*5
