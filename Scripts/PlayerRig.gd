extends Node3D
# todo:将palyerRig脚本移动到PlayerModel上
# 与StateMachine功能冲突 用来测试其他的动画控制方式
# 该类主要控制玩家的行为动画与配合动画的位移
@onready var animation_tree: AnimationTree = get_node_or_null("../BlendAnimationTree")
@onready var play_back: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback") if animation_tree else null
@onready var player: Node = get_node_or_null("../..")

@onready var health_component: HealthComponent = get_node_or_null("../../HealthComponent")
@onready var collision_shape_3d: CollisionShape3D = get_node_or_null("../../CollisionShape3D")
@onready var state_machine: StateMachine = get_node_or_null("../../StateMachine")
@onready var dash: Dash = get_node_or_null("../../StateMachine/Dash")
@onready var interaction_cast: interaction_cast = get_node_or_null("../InteractionCast")
@onready var right_hand_slot: Node3D = $RightHandAttach/RightHandSlot
@onready var left_hand_slot: Node3D = $LeftHandAttach/LeftHandSlot
@onready var rogue_cape: MeshInstance3D = $Skeleton3D/chest/Rogue_Cape

@export var animation_speed: float = 10.0
@export var attack_move_distance: float = 1.5

var run_path: String = "parameters/MoveSpace/blend_position"
var run_weight_target := -1.0

## 当 Rig 处于非 Player 场景中（如 inventory 预览），游戏逻辑节点不存在，自动降级为纯展示模式
var _is_preview_mode: bool = false


func _ready() -> void:
	# 检测是否在预览场景中（player 不是 Player 类型说明不在游戏场景中）
	if player == null or not (player is Player):
		_is_preview_mode = true
		set_physics_process(false)
		return

	# 连接击败信号（仅在完整游戏场景中）
	if health_component and not health_component.defeat.is_connected(_on_health_component_defeat):
		health_component.defeat.connect(_on_health_component_defeat)

func _physics_process(delta: float) -> void:
	if _is_preview_mode:
		return

	if player != null and (player as Player):
		# 移动
		update_animation_tree(player.Direction)
		if animation_tree:
			animation_tree[run_path] = move_toward(
				animation_tree[run_path],
				run_weight_target,
				animation_speed * delta
			)
		# 处理与拾取物品的交互
		interaction_cast.check_interactions()
		# 攻击
		if play_back:
			if player.IsDash == true and not check_state("Dash") and dash and dash.is_readly():
				play_back.travel("Dash")

		handle_slashing_physics_frame(delta)

func _on_health_component_defeat() -> void:
	if _is_preview_mode:
		return
	if play_back:
		play_back.travel("Defeat")
	if player:
		player.IsDefeat = true
	set_physics_process(false)
	set_process_input(false)
	if state_machine:
		state_machine.change_state("Defeat")

func update_animation_tree(diretion: Vector3) -> void:
	if diretion.is_zero_approx():
		run_weight_target = -1.0
	else:
		run_weight_target = 1.0

func check_state(state_name: String) -> bool:
	if play_back == null:
		return false
	return play_back.get_current_node() == state_name

func handle_slashing_physics_frame(delta: float) -> void:
	if _is_preview_mode or player == null or not (player is Player):
		return
	if not (check_state("Attack") or check_state("Dash")):
		return
	if check_state("Attack"):
		player.velocity.x = player.CurDirection.x * attack_move_distance
		player.velocity.z = player.CurDirection.z * attack_move_distance
	if check_state("Dash"):
		player.velocity.x = player.CurDirection.x * attack_move_distance * 5
		player.velocity.z = player.CurDirection.z * attack_move_distance * 5
		
func replace_hand_item(item_scene:PackedScene,right_side:bool) -> void:
	if right_side:
		for child in right_hand_slot.get_children():
			child.queue_free()
		if item_scene!=null:
			var new_item:=item_scene.instantiate()
			right_hand_slot.add_child(new_item)
	else:
		for child in left_hand_slot.get_children():
			child.queue_free()
		if item_scene!=null:
			var new_item:=item_scene.instantiate()
			left_hand_slot.add_child(new_item)
	
func use_armor(use_flag:bool) -> void:
	rogue_cape.visible=use_flag
