extends Node
class_name HealthComponent

@onready var player: CharacterBody3D =get_owner()

signal defeat()
signal health_change(new_health: float)

func _ready() -> void:
	if player is Player and player.MyStats:
		player.MyStats.connect("LevelUp", Callable(self, "_on_level_up"))
		update_max_health(player.MyStats.GetMaxHp())

var max_health:float
var cur_health:float:
	set(value):
		cur_health=max(0.0,value)
		if cur_health==0:
			defeat.emit()
		if player is Player and player.MyStats:
			player.MyStats.CurHealth=cur_health
		health_change.emit(cur_health)

func update_max_health(value:float) -> void:
	max_health=value
	cur_health=max_health
	if player is Player and player.MyStats:
		player.MyStats.CurHealth=cur_health
	
func take_damage(damage_in:float) -> void:
	cur_health-=damage_in
	
func _on_level_up() -> void:
	if player as Player:
		update_max_health(player.MyStats.GetMaxHp())
