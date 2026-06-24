extends Control
class_name user_interface

@onready var player: Player =get_owner()
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var level_label: Label = %LevelLabel
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var xp_bar: TextureProgressBar = %XpBar
@onready var hp_label: Label = %HpLabel
@onready var inventory: Inventory = $inventory
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_container: VBoxContainer = $HUD/InteractContainer
@onready var interactt_text: Label = $HUD/InteractContainer/InteracttText


func _ready() -> void:
	if player is Player and player.MyStats:
		player.MyStats.connect("LevelUp", Callable(self, "_on_level_up"))
		player.MyStats.connect("XpUp", Callable(self, "_on_xp_up"))
		health_bar.max_value = player.MyStats.GetMaxHp()
		health_bar.value = player.MyStats.CurHealth
		_updata_health_num()
		health_component.connect("health_change", Callable(self, "_on_health_change"))
		inventory.updata_attribute()
		interact_container.visible=false
		_on_level_up()
		
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		inventory.controll_visible()

func _on_health_change(new_health: float) -> void:
	health_bar.value = new_health
	health_bar.max_value=player.MyStats.GetMaxHp()
	health_bar.value=player.MyStats.CurHealth
	_updata_health_num()

func _on_level_up() -> void:
	if player as Player:
		level_label.text=str(player.MyStats.Level)
		xp_bar.max_value=player.MyStats.PercentageLevelUpBoundary()
		xp_bar.value=player.MyStats.Xp
		if int(inventory.level_label.text.substr(6))!=player.MyStats.Level:
			inventory.updata_attribute()

func _on_xp_up() -> void:
	if player as Player:
		xp_bar.value=player.MyStats.Xp
		
func _updata_health_num() -> void:
	var label_text:="%s/%s" % [str(player.MyStats.CurHealth),str(player.MyStats.GetMaxHp())]
	hp_label.text=label_text
	
func show_interact_text(text:String) -> void:
	animation_player.stop()
	animation_player.play("FadeOutInteractText")
	interactt_text.text=text
