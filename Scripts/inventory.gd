extends Control
class_name Inventory
@onready var player: Player =get_parent().get_owner()
@onready var strength_value: Label = %StrengthValue
@onready var speed_value: Label = %SpeedValue
@onready var endurance_value: Label = %EnduranceValue
@onready var agility_value: Label = %AgilityValue
@onready var level_label: Label = %LevelLabel
@onready var damage_value: Label = %DamageValue
@onready var armor_value: Label = %ArmorValue
@onready var item_grid: GridContainer = %ItemGrid
@onready var gold_num_label: Label = %GoldNumLabel
@onready var weapon_slot: CenterContainer = %WeaponSlot
@onready var shield_slot: CenterContainer = %ShieldSlot
@onready var armor_slot: CenterContainer = %ArmorSlot

var gold_num:=0:
	set(value):
		gold_num=value
		gold_num_label.text=str(value)+'G'
		
func get_weapon_value() -> int:
	if weapon_slot.get_child_count()==0:
		return 0
	else:
		var weapon_item=weapon_slot.get_child(0) as weapon_icon
		return int(weapon_item.num_label.text)
		
func get_armor_value() -> int:
	var armor:=0
	if armor_slot.get_child_count()>0:
		var armor_item=armor_slot.get_child(0) as armor_icon
		armor+=int(armor_item.num_label.text)
	if shield_slot.get_child_count()>0:
		var shield_item=shield_slot.get_child(0) as shield_icon
		armor+=int(shield_item.num_label.text)
	
	return clamp(armor, 0, 80)

func updata_attribute() -> void:
	level_label.text="Level "+str(player.MyStats.Level)
	strength_value.text="%.2f" % player.MyStats.Strength.GetValue()
	speed_value.text="%.2f" % player.MyStats.Speed.GetValue()
	endurance_value.text="%.2f" % player.MyStats.Endurance.GetValue()
	agility_value.text="%.2f" % player.MyStats.Agility.GetValue()
	player.MyStats.WeaponDamage=get_weapon_value()
	damage_value.text="%.2f" % (player.MyStats.Strength.GetValue()+get_weapon_value())
	player.MyStats.Armor=get_armor_value()
	armor_value.text="%.2f" % player.MyStats.Armor

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
		for connection in icon.item_interact.get_connections():
			icon.item_interact.disconnect(connection.callable)
		icon.item_interact.connect(interact)
		
func equipping_item(item: ItemIcon,item_slot:CenterContainer) -> void:
	for child in item_slot.get_children():
		add_item(child)
	item.get_parent().remove_child(item)
	item_slot.add_child(item)
	
func interact(item:ItemIcon) -> void:
	if item is weapon_icon:
		equipping_item(item,weapon_slot)
	elif item is armor_icon:
		equipping_item(item,armor_slot)
	elif item is shield_icon:
		equipping_item(item,shield_slot)
	updata_attribute()
	
