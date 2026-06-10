extends Node
class_name HealthComponent

signal defeat()
signal health_change()

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
