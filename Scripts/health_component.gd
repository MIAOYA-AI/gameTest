extends Node
class_name HealthComponent

@onready var player: CharacterBody3D =get_owner()

signal defeat()
signal health_change()

func _ready() -> void:
	connect("LevelUp",Callable(self,"_on_level_up"))

var max_health:float
var cur_health:float:
	set(value):
		cur_health=max(0.0,value)
		print(cur_health)
		if cur_health==0:
			defeat.emit()
		health_change.emit()

func update_max_health(value:float) -> void:
	max_health=value
	cur_health=max_health
	
func take_damage(damage_in:float) -> void:
	cur_health-=damage_in
	
func _on_level_up() -> void:
	if player as Player:
		update_max_health(player.MyStats.GetMaxHp())
