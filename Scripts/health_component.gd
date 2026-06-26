extends Sprite3D
class_name HealthComponent

@onready var player: CharacterBody3D = get_owner()
@onready var sub_viewport: SubViewport = get_node_or_null("SubViewport")
@onready var progress_bar: ProgressBar = get_node_or_null("SubViewport/ProgressBar") if sub_viewport else null

signal defeat()
signal health_change(new_health: float)

var max_health: float
var cur_health: float:
	set(value):
		var old_health = cur_health
		cur_health = max(0.0, value)
		if cur_health == 0:
			defeat.emit()
		if player is Player and player.MyStats:
			player.MyStats.CurHealth = cur_health
		health_change.emit(cur_health)
		_animate_health_bar(old_health, cur_health)

var health_tween: Tween


func _ready() -> void:
	_setup_health_bar()

	if player is Player and player.MyStats:
		player.MyStats.connect("LevelUp", Callable(self, "_on_level_up"))
		update_max_health(player.MyStats.GetMaxHp())
		load_health_from_persistant_data()


func _setup_health_bar() -> void:
	if not sub_viewport:
		return

	if player is Player:
		# Player 类型：隐藏 3D 血条（Player 有自己的 UI 显示血量）
		visible = false
		return

	# 非 Player 类型（Enemy / EnemyTree）：显示血条
	visible = true
	# 延迟一帧更新位置，确保父节点的 CollisionShape3D 已就绪
	call_deferred("_update_bar_position")


func _update_bar_position() -> void:
	if not player:
		return
	# self 必须是 Node3D（Sprite3D）才能设置 3D 位置
	if not self is Node3D:
		return

	var collision_shape: CollisionShape3D = player.get_node_or_null("CollisionShape3D")
	if not collision_shape or not collision_shape.shape:
		return

	var shape = collision_shape.shape
	var shape_height: float = 0.0

	if shape is CapsuleShape3D:
		shape_height = shape.height
	elif shape is BoxShape3D:
		shape_height = shape.size.y
	elif shape is CylinderShape3D:
		shape_height = shape.height
	elif shape is SphereShape3D:
		shape_height = shape.radius * 2.0
	else:
		return

	# 血条放到 CollisionShape3D 顶端上方
	var bar_offset := shape_height / 2.0 + 0.3
	var target_y := collision_shape.position.y + bar_offset
	(self as Node3D).position = Vector3(0.0, target_y, 0.0)


func _animate_health_bar(old_health: float, new_health: float) -> void:
	if not progress_bar or player is Player:
		return
	if is_equal_approx(old_health, new_health):
		return
	# 首次初始化时跳过动画（old_health 为默认值 0 且 max_health 已设置）
	if is_zero_approx(old_health) and new_health > 0 and not (health_tween and health_tween.is_valid()):
		progress_bar.value = new_health
		return

	if health_tween and health_tween.is_valid():
		health_tween.kill()

	progress_bar.value = old_health
	health_tween = create_tween()
	health_tween.tween_property(progress_bar, "value", new_health, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func load_health_from_persistant_data() -> void:
	if PersistentData.cache_health != 0:
		cur_health = PersistentData.cache_health


func update_max_health(value: float) -> void:
	max_health = value
	if progress_bar:
		progress_bar.max_value = max_health
	cur_health = max_health
	if player is Player and player.MyStats:
		player.MyStats.CurHealth = cur_health


func take_damage(damage_in: float) -> void:
	if player is Player and player.MyStats:
		damage_in *= (1.0 - player.MyStats.Armor / 100.0)
	cur_health -= damage_in


func _on_level_up() -> void:
	if player as Player:
		update_max_health(player.MyStats.GetMaxHp())
