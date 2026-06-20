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
	item_grid.add_child(icon)
