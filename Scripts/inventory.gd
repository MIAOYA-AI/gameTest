extends Control
class_name inventory
@onready var strength_value: Label = %StrengthValue
@onready var speed_value: Label = %SpeedValue
@onready var endurance_value: Label = %EnduranceValue
@onready var agility_value: Label = %AgilityValue
@onready var level_label: Label = %LevelLabel


func updata_attribute(player_stats:CharacterStats) -> void:
	level_label.text="Level "+str(player_stats.Level)
	strength_value.text="%.2f" % player_stats.Strength.GetValue()
	speed_value.text="%.2f" % player_stats.Speed.GetValue()
	endurance_value.text="%.2f" % player_stats.Endurance.GetValue()
	agility_value.text="%.2f" % player_stats.Agility.GetValue()
