extends Control

@onready var player: Player =get_owner()
@onready var level_label: Label = %LevelLabel
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var xp_bar: TextureProgressBar = %XpBar

func _ready() -> void:
	if player is Player and player.MyStats:
		player.MyStats.connect("LevelUp", Callable(self, "_on_level_up"))

func _on_level_up() -> void:
	if player as Player:
		level_label.text=str(player.MyStats.Level)
		xp_bar.max_value=player.MyStats.PercentageLevelUpBoundary()
		xp_bar.value=player.MyStats.Xp
		health_bar.max_value=player.MyStats.GetMaxHp()
