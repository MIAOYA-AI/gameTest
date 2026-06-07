extends Node3D
# 与StateMachine功能冲突 用来测试其他的动画控制方式
@onready var animation_tree: AnimationTree = $"../BlendAnimationTree"
@export var player:Player

@export var animation_speed:float=10.0

var run_path:String = "parameters/BlendSpace1D/blend_position"
var run_weight_target:=-1.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	update_animation_tree(player.Direction)
	animation_tree[run_path]=move_toward(
		animation_tree[run_path],
		run_weight_target,
		animation_speed*delta
	)

func update_animation_tree(diretion:Vector3) ->void:
	if diretion.is_zero_approx():
		run_weight_target=-1.0
	else:
		run_weight_target=1.0
