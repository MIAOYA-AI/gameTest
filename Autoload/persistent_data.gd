extends Control

@onready var inventory_node: Control = $InventoryNode

func cache_inventory(player:Player) -> void:
	for item in (player.UserInterface as user_interface).inventory.item_grid.get_children():
		item.get_parent().remove_child(item)
		inventory_node.add_child(item)
		
func get_inventory() -> Array:
	return inventory_node.get_children()

func cache_equipment() -> void:
	pass
