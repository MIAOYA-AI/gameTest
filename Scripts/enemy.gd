extends CharacterBody3D

class_name Enemy

const RUN_VELOCITY_THRESHOLD:=2

@export var max_health:float=100
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var skeleton_3d: Skeleton3D = $model/CharacterRig/GameRig/Skeleton3D
@onready var animation_tree: AnimationTree = $model/CharacterRig/AnimationTree
@onready var play_back:AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var health_component: HealthComponent = $HealthComponent
@onready var player_detector: ShapeCast3D = $model/PlayerDetector
@onready var area_attack: ShapeCast3D = $AreaAttack
@onready var player:Player=get_tree().get_first_node_in_group("Player")
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var left_hand_slot: Node3D = %LeftHandSlot
@onready var right_hand_slot: Node3D = %RightHandSlot
@export var shields:Array[PackedScene]
@export var weapoms:Array[PackedScene]


@onready var villager_meshes: Array[MeshInstance3D]=[
	$model/CharacterRig/GameRig/Skeleton3D/Villager_01,
	$model/CharacterRig/GameRig/Skeleton3D/Villager_02
]

var run_path="parameters/MoveSpace/blend_position"

func _ready():
	# 随机更换敌人外观
	random_active_mesh()
	# 随机装备
	_random_equipment()
	health_component.update_max_health(max_health)

func _physics_process(_delta: float) -> void:
	check_for_player(_delta)
	if check_state("MoveSpace"):
		check_for_attacks()
	
	# 如果在攻击状态关闭躲避掩码
	if check_state("Overhead") or check_state("OverheadRecover"):
		navigation_agent_3d.avoidance_mask=0
	else:
		navigation_agent_3d.avoidance_mask=1
		
	if !is_on_floor():
		velocity.y+=get_gravity().y*_delta

func check_for_player(_delta: float) ->void:
	navigation_agent_3d.target_position = player.global_position
	# 将目标高度与模型位置齐平
	navigation_agent_3d.target_position.y = global_position.y
	# 已接近目标则停止移动
	if navigation_agent_3d.is_target_reached():
		return

	var next_point := navigation_agent_3d.get_next_path_position()
	# 避免原点与目标重合时 look_at() 报错
	if global_position.is_equal_approx(next_point):
		return

	# 将路径点高度拉平，避免模型倾斜
	next_point.y = global_position.y
	look_at(next_point, Vector3.UP, true)
	
	# 获取局部的方向向量
	var destination =(navigation_agent_3d.get_next_path_position()-global_position).normalized()
	velocity.x=destination.x
	velocity.z=destination.z
	# 給出速度使避障算法进行运算
	navigation_agent_3d.velocity=velocity
	# 在避障算法的回调中再最终移动
	#move_and_slide()

# 检测玩家 并判断是否发起攻击
func check_for_attacks() -> void:
	for collision_id in player_detector.get_collision_count():
		var collider = player_detector.get_collider(collision_id)
		if collider is Player:
			play_back.travel("Overhead")

func random_active_mesh() -> void:
	for child in skeleton_3d.get_children():
		child.visible=false
	villager_meshes.pick_random().visible=true

func check_state(state_name:String) -> bool:
	return play_back.get_current_node()==state_name

func _on_health_component_defeat() -> void:
	play_back.travel("Defeat")
	collision_shape_3d.disabled=true;
	set_physics_process(false)
	player.MyStats.IncreaseXp(100)
	#queue_free()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Overhead":
		area_attack.deal_damage(100)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if check_state("Defeat"):
		return
	velocity.x=safe_velocity.x
	velocity.z=safe_velocity.z
	if velocity.length()<RUN_VELOCITY_THRESHOLD:
		animation_tree[run_path]=0
	else:
		animation_tree[run_path]=1
	if !check_state("Overhead") and !check_state("OverheadRecover"):
		move_and_slide()
		

func _random_equipment() -> void:
	for child in right_hand_slot.get_children():
		child.queue_free()
	right_hand_slot.add_child(shields.pick_random().instantiate())
	
	for child in left_hand_slot.get_children():
		child.queue_free()
	left_hand_slot.add_child(weapoms.pick_random().instantiate())
	
