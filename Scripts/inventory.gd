extends Control
class_name Inventory
@onready var strength_value: Label = %StrengthValue
@onready var speed_value: Label = %SpeedValue
@onready var endurance_value: Label = %EnduranceValue
@onready var agility_value: Label = %AgilityValue
@onready var level_label: Label = %LevelLabel
@onready var damage_value: Label = %DamageValue
@onready var player: Player =get_parent().get_owner()
@onready var item_grid: GridContainer = %ItemGrid
@onready var gold_num_label: Label = %GoldNumLabel
@onready var weapon_slot: CenterContainer = %WeaponSlot
@onready var shield_slot: CenterContainer = %ShieldSlot
@onready var armor_slot: CenterContainer = %ArmorSlot

var gold_num:=0:
	set(value):
		gold_num=value
		gold_num_label.text=str(value)+'G'

func updata_attribute() -> void:
	level_label.text="Level "+str(player.MyStats.Level)
	strength_value.text="%.2f" % player.MyStats.Strength.GetValue()
	speed_value.text="%.2f" % player.MyStats.Speed.GetValue()
	endurance_value.text="%.2f" % player.MyStats.Endurance.GetValue()
	agility_value.text="%.2f" % player.MyStats.Agility.GetValue()
	damage_value.text="%.2f" % player.MyStats.Strength.GetValue()

func controll_visible()-> void:
	visible=!visible
	get_tree().paused=visible
	if visible:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _on_back_button_pressed() -> void:
	controll_visible()

func add_item(icon:ItemIcon) -> void:
	icon.get_parent().remove_child(icon)
	if (icon as currency_icon):
		gold_num+=int(icon.num_label.text)
		icon.queue_free()
	else:
		item_grid.add_child(icon)
		icon.item_interact.connect(equipping_item)
		
func equipping_item(icon: ItemIcon) -> void:
	# 图标类型 → 对应装备槽的映射表
	var slot_map := {
		weapon_icon: weapon_slot,
		shield_icon: shield_slot,
		armor_icon: armor_slot,
	}

	var target_slot: CenterContainer = null
	for icon_type in slot_map:
		if is_instance_of(icon, icon_type):
			target_slot = slot_map[icon_type]
			break

	if target_slot == null:
		return

	if icon.get_parent() == item_grid:
		# 从物品栏装备到槽位
		item_grid.remove_child(icon)
		if target_slot.get_child_count() > 0:
			var replace_icon := target_slot.get_child(0)
			target_slot.remove_child(replace_icon)
			item_grid.add_child(replace_icon)
		target_slot.add_child(icon)
	else:
		# 从槽位卸下到物品栏
		target_slot.remove_child(icon)
		item_grid.add_child(icon)
