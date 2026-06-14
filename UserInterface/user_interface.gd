extends Control

@onready var player: Player =get_owner()
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
	if player is Player and player.MyStats:
		player.MyStats.connect("LevelUp", Callable(self, "_on_level_up"))

func _on_level_up() -> void:
	if player as Player:
		level_label.text=str(player.MyStats.Level)
