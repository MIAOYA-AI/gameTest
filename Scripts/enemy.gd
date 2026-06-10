extends CharacterBody3D

class_name Enemy

@export var max_health:float=100
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var skeleton_3d: Skeleton3D = $model/CharacterRig/GameRig/Skeleton3D
@onready var animation_tree: AnimationTree = $model/CharacterRig/AnimationTree
@onready var play_back:AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var health_component: HealthComponent = $HealthComponent
@onready var player_detector: ShapeCast3D = $model/PlayerDetector
@onready var area_attack: ShapeCast3D = $AreaAttack

@onready var villager_meshes: Array[MeshInstance3D]=[
	$model/CharacterRig/GameRig/Skeleton3D/Villager_01,
	$model/CharacterRig/GameRig/Skeleton3D/Villager_02
]

func _ready():
	# 随机更换敌人外观
	random_active_mesh()
	health_component.update_max_health(max_health)

func _physics_process(_delta: float) -> void:
	if check_state("MoveSpace"):
		check_for_attacks()

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
	#queue_free()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Overhead":
		area_attack.deal_damage(100)
