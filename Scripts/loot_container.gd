extends CenterContainer
class_name loot_container
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/GridContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleTexture/TitleLabel

@export var inventory: Inventory

var current_chect:Chect

func _ready() -> void:
	visible=false
	
func close() -> void:
	for item in grid_container.get_children():
		grid_container.remove_child(item)
		item.visible=false
		item.item_interact.disconnect(pickup_item)
		current_chect.add_child(item)
	visible=false
	current_chect=null
	#Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func open(loot:Chect) -> void:
	current_chect=loot
	title_label.text=loot.name.capitalize()
	for item in loot.get_items():
		item=item as ItemIcon
		current_chect.remove_child(item)
		grid_container.add_child(item)
		item.visible=true
		item.item_interact.connect(pickup_item)
	visible=true
	#Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func _on_back_button_pressed() -> void:
	close()
	
func pickup_item(icon:ItemIcon) -> void:
	icon.item_interact.disconnect(pickup_item)
	inventory.add_item(icon)
