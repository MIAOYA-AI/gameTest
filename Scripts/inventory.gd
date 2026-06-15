extends Control
class_name inventory
@onready var strength_value: Label = %StrengthValue
@onready var speed_value: Label = %SpeedValue
@onready var endurance_value: Label = %EnduranceValue
@onready var agility_value: Label = %AgilityValue
@onready var level_label: Label = %LevelLabel
@onready var player: Player =get_parent().get_owner()


func updata_attribute() -> void:
	level_label.text="Level "+str(player.MyStats.Level)
	strength_value.text="%.2f" % player.MyStats.Strength.GetValue()
	speed_value.text="%.2f" % player.MyStats.Speed.GetValue()
	endurance_value.text="%.2f" % player.MyStats.Endurance.GetValue()
	agility_value.text="%.2f" % player.MyStats.Agility.GetValue()
