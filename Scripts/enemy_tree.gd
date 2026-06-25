extends CharacterBody3D

@onready var vision_ray: RayCast3D = $VisionRay
@onready var animation_player: AnimationPlayer = $model/Barbarian/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var target:Player
@export var patrol_points: Array[Node3D] = []#巡逻点
@export var speed_walk:float=1.7
@export var speed_run:float=3.0
@export var speed_retreat:float=5.0
@export var speed_rush:float=6.0
@export var attack_range:float=2.0
@export var attack_wait_time:float=5.0
@export var dash_wait_time:float=1.0
@export var investigate_wait_time:float=4.0
@export var patrol_wait_time:float=1.0
@export var update_interval:float=0.2

const UPDATE_TIME=0.2
const SPEED=150
const SMOOTHING_FACTOR=0.1
const VIEW_ANGLE:float=150.0

enum State {IDLE,PATROL,INVESTIGATE,CHASE,PREPARE_ATTACK,ATTACK,RETURN}
var state:State=State.IDLE

var attack_anim_name:String
var patrol_index:=0
var patrol_timer:=0.0
var investigate_timer:=0.0
var attack_wait_timer:=0.0
var dash_wait_timer:=0.0
var prepare_attack_phase:=0 ## 0=后撤, 1=保持距离, 2=突击
var strafe_dir_sign:=1.0 ## 左右踱步方向 1=右 -1=左
var update_timer:=0.0
var investigate_position:Vector3
var return_position:Vector3 #原始位置
var gravity:float=ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# 导入的动画默认不循环，手动设置为循环播放
	_init_animation_loop()
	_enter_state(State.IDLE if patrol_points.is_empty() else State.PATROL)
	
func _init_animation_loop() -> void:
	_set_animation_loop("Idle")
	_set_animation_loop("Walking_A")

func _set_animation_loop(anim_name: String) -> void:
	var anim := animation_player.get_animation(anim_name)
	if anim:
		anim.loop_mode = Animation.LOOP_LINEAR

func _physics_process(delta: float) -> void:
	_update_path(delta)
	
	match state:
		State.IDLE: _state_idle()
		State.PATROL: _state_patrol(delta)
		State.INVESTIGATE: _state_investigate(delta)
		State.CHASE: _state_chace(delta)
		State.PREPARE_ATTACK: _state_prepare_attack(delta)
		State.ATTACK: _state_attack(delta)
		State.RETURN: _state_return(delta)
	
	_looking()
	_apply_gravity(delta)
	move_and_slide()

# 确定下一个巡查点 可随机选取
func _go_to_next_patrol_point() -> void:
	navigation_agent_3d.set_target_position(patrol_points[patrol_index].global_transform.origin)
	patrol_index = (patrol_index + 1) % patrol_points.size()
	
func _move_towards(next_position:Vector3, speed:float) -> void:
	var dir = (next_position - global_transform.origin)
	dir.y=0.0
	if is_zero_approx(dir.length()):
		velocity.x=lerp(velocity.x,0.0,SMOOTHING_FACTOR)
		velocity.y=lerp(velocity.y,0.0,SMOOTHING_FACTOR)
		return
		
	dir = dir.normalized()
	var current_facing=-global_transform.basis.z
	var new_dir=current_facing.slerp(dir,SMOOTHING_FACTOR).normalized()
	look_at(global_transform.origin + new_dir,Vector3.UP)
	#DebugDraw3D.draw_line(global_transform.origin,global_transform.origin+new_dir*5.0,Color.RED,0.1)
	
	velocity.x=dir.x*speed
	velocity.z=dir.z*speed
	
func _stop_and_idle() -> void:
	velocity=Vector3.ZERO
	animation_player.play("Idle")
	
func _walk_to(next_position:Vector3 , speed:float) -> void:
	if speed==speed_walk:
		animation_player.play("Walking_A")
	elif speed==speed_run:
		animation_player.play("Running_A")
	_move_towards(next_position,speed)
	
# 更新导航目标
func _update_agent_target() -> void:
	match state:
		State.PATROL:
			pass  # 巡逻目标只在 _go_to_next_patrol_point() 中设置，无需定时更新
		State.INVESTIGATE:
			navigation_agent_3d.set_target_position(investigate_position)
		State.CHASE:
			if target:
				navigation_agent_3d.set_target_position(target.global_transform.origin)
		State.RETURN:
			navigation_agent_3d.set_target_position(return_position)
			
func _update_path(delate):
	update_timer-=delate
	if update_timer<=0.0:
		_update_agent_target()
		update_timer=update_interval
		
func _apply_gravity(delta:float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
		
func _can_see_player() -> bool:
	return target and vision_ray.is_colliding() and vision_ray.get_collider()==target
	
func _looking() -> void:
	if not target:
		return
	# 计算视角
	var to_player = (target.global_transform.origin-global_transform.origin).normalized()
	var forward=-global_transform.basis.z#默认获取到的值已归一化
	var angle_deg=rad_to_deg(acos(clamp(forward.dot(to_player),-1.0,1.0)))# 夹在cos范围中间
	if angle_deg>VIEW_ANGLE*0.5:
		return
	var ray_forward=-vision_ray.global_transform.basis.z
	var new_dir=ray_forward.slerp(to_player,SMOOTHING_FACTOR).normalized()
	vision_ray.look_at(vision_ray.global_transform.origin+new_dir,Vector3.UP)
		
func _enter_state(new_state:State) -> void:
	state=new_state
	match state:
		State.PATROL:
			patrol_timer=0
			_go_to_next_patrol_point()
		State.INVESTIGATE:
			investigate_timer=0.0
			navigation_agent_3d.target_position=investigate_position
		State.CHASE,State.INVESTIGATE:
			return_position=global_transform.origin
		State.PREPARE_ATTACK:
			prepare_attack_phase=0
			
func _state_idle() -> void:
	if _can_see_player():
		_enter_state(State.CHASE)
			
func _state_patrol(delta:float) -> void:
	#在一次导航结束后 先让敌人停止等待一个patrol_wait_time的周期结束再前往下一个目标点
	if navigation_agent_3d.is_navigation_finished():
		if patrol_timer<=0.0:
			patrol_timer=patrol_wait_time
			_stop_and_idle()
		else:
			patrol_timer-=delta
			if patrol_timer<=0.0:
				_go_to_next_patrol_point()
	else:
		_walk_to(navigation_agent_3d.get_next_path_position(),speed_walk)
	
	if _can_see_player():
		_enter_state(State.CHASE)
	
func _state_chace(delta:float) -> void:
	print("enemy chace")
	if not target:
		_enter_state(State.RETURN)
		return
	
	_walk_to(navigation_agent_3d.get_next_path_position(),speed_run)
	
	if global_transform.origin.distance_to(target.global_transform.origin) < attack_range:
		_enter_state(State.ATTACK)
	elif not _can_see_player():
		investigate_position=target.global_transform.origin
		_enter_state(State.INVESTIGATE)
		
func _state_attack(_delta:float) -> void:
	velocity=Vector3.ZERO

	# 当前正在播放攻击动画，等待动画结束
	if attack_anim_name!="":
		if not animation_player.is_playing():
			attack_anim_name=""
			_enter_state(State.CHASE)
		return

	# 攻击冷却中，进入准备攻击状态
	attack_wait_timer-=_delta
	if attack_wait_timer>0:
		_enter_state(State.PREPARE_ATTACK)
		return

	# 发起攻击
	print("enemy attack")
	var attack_anim:=[
		"1H_Melee_Attack_Slice_Diagonal",
		"1H_Melee_Attack_Chop",
		"1H_Melee_Attack_Slice_Horizontal",
		"2H_Melee_Attack_Chop",
		"2H_Melee_Attack_Slice",
		"2H_Melee_Attack_Spin"]
	attack_anim_name=attack_anim.pick_random()
	attack_wait_timer=attack_wait_time
	animation_player.play(attack_anim_name)
	
func _state_prepare_attack(delta:float) -> void:
	if not target:
		_enter_state(State.RETURN)
		return

	var dist:=global_transform.origin.distance_to(target.global_transform.origin)

	# 玩家超出攻击范围3倍，切换追击
	if dist>attack_range*3:
		_enter_state(State.CHASE)
		return

	attack_wait_timer-=delta
	dash_wait_timer-=delta

	match prepare_attack_phase:
		0: # 后撤阶段 — 面朝玩家、向后快速移动，播放Dodge_Backward
			# 如果后撤的冷却时间没有结束 且后撤动画已经播放完成 则进入保持距离的状态
			if dash_wait_timer>0 and not (animation_player.is_playing() and animation_player.current_animation=="Dodge_Backward"):
				prepare_attack_phase=1
				return
			var to_player:=(target.global_transform.origin-global_transform.origin)
			to_player.y=0.0
			if not is_zero_approx(to_player.length()):
				to_player=to_player.normalized()
				# 面朝玩家
				look_at(global_transform.origin+to_player,Vector3.UP)
				# 朝玩家反方向移动
				velocity.x=-to_player.x*speed_retreat
				velocity.z=-to_player.z*speed_retreat
				animation_player.play("Dodge_Backward")
				dash_wait_timer=dash_wait_time
			
			if dist>=attack_range*2:
				prepare_attack_phase=1
				strafe_dir_sign=1.0 if randf()>0.5 else -1.0
			elif dist<attack_range:
				_enter_state(State.ATTACK)

		1: # 保持距离阶段 — 与玩家维持attack_range*2距离，等待冷却结束
			if dist>attack_range*2+0.5:
				# 太远，靠近玩家
				var to_player:=(target.global_transform.origin-global_transform.origin)
				to_player.y=0.0
				if not is_zero_approx(to_player.length()):
					to_player=to_player.normalized()
					look_at(global_transform.origin+to_player,Vector3.UP)
					velocity.x=to_player.x*speed_walk
					velocity.z=to_player.z*speed_walk
				animation_player.play("Walking_A")
			# 如果玩家拉近距离并且后撤冷却结束则后撤
			elif dist<attack_range and dash_wait_timer<=0:
				prepare_attack_phase=0
			elif dist<attack_range*2-0.5:
				# 太近，面朝玩家向后移动
				var to_player:=(target.global_transform.origin-global_transform.origin)
				to_player.y=0.0
				if not is_zero_approx(to_player.length()):
					to_player=to_player.normalized()
					look_at(global_transform.origin+to_player,Vector3.UP)
					velocity.x=-to_player.x*speed_walk
					velocity.z=-to_player.z*speed_walk
				animation_player.play("Walking_Backwards")
			else:
				# 距离合适，左右踱步（方向在进入阶段1时已随机确定，一个冷却周期内不变）
				var to_player:=(target.global_transform.origin-global_transform.origin)
				to_player.y=0.0
				if not is_zero_approx(to_player.length()):
					to_player=to_player.normalized()
					look_at(global_transform.origin+to_player,Vector3.UP)
					# 计算右方向向量
					var right_dir:=to_player.cross(Vector3.UP).normalized()
					var move_dir:=right_dir*strafe_dir_sign
					velocity.x=move_dir.x*speed_run
					velocity.z=move_dir.z*speed_run
					if strafe_dir_sign>0:
						animation_player.play("Running_Strafe_Right")
					else:
						animation_player.play("Running_Strafe_Left")

			if attack_wait_timer<=0:
				prepare_attack_phase=2

		2: # 突击阶段 — 快速冲向玩家，播放Dodge_Forward
			var to_player:=(target.global_transform.origin-global_transform.origin)
			to_player.y=0.0
			if not is_zero_approx(to_player.length()):
				to_player=to_player.normalized()
				look_at(global_transform.origin+to_player,Vector3.UP)
				velocity.x=to_player.x*speed_rush
				velocity.z=to_player.z*speed_rush
			animation_player.play("Dodge_Forward")
			if dist<=attack_range:
				_enter_state(State.ATTACK)

func _state_investigate(delta:float) -> void:
	print("enemy investigate")
	if navigation_agent_3d.is_navigation_finished():
		if investigate_timer<=0.0:
			investigate_timer=investigate_wait_time
			_stop_and_idle()
		else:
			investigate_timer-=delta
			if investigate_timer<=0.0:
				_enter_state(State.RETURN)
				
	else:
		_walk_to(navigation_agent_3d.get_next_path_position(),speed_walk)
		
	if _can_see_player():
		_enter_state(State.CHASE)
		
func _state_return(delta:float) -> void:
	print("enemy return")
	if navigation_agent_3d.is_navigation_finished():
		_enter_state(State.PATROL)
	else:
		_walk_to(navigation_agent_3d.get_next_path_position(),speed_walk)
		
	if _can_see_player():
		_enter_state(State.CHASE)
		
# 通过检查音源在外部让敌人进入调查状态
func hear_noise(pos:Vector3) -> void:
	if state not in [State.CHASE,State.PREPARE_ATTACK,State.ATTACK]:
		investigate_position=pos
		_enter_state(State.INVESTIGATE)
