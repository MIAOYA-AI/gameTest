extends Control

@onready var inventory_node: Control = $InventoryNode
@onready var shield_node: Control = $ShieldNode
@onready var armor_node: Control = $ArmorNode
@onready var weapon_node: Control = $WeaponNode

var cache_gold:=0
var cache_health:=0

func cache_inventory(player:Player) -> void:
	for item in (player.UserInterface as user_interface).inventory.item_grid.get_children():
		cache_item(item,inventory_node)
	cache_item((player.UserInterface as user_interface).inventory.weapon_slot.get_child(0),weapon_node)
	cache_item((player.UserInterface as user_interface).inventory.shield_slot.get_child(0),shield_node)
	cache_item((player.UserInterface as user_interface).inventory.armor_slot.get_child(0),armor_node)
	
func cache_player_data(player:Player) -> void:
	cache_gold=(player.UserInterface as user_interface).inventory.gold_num
	cache_health=player.MyStats.CurHealth
	
func get_inventory() -> Array:
	return inventory_node.get_children()
	
func get_equipped_items() -> Array:
	var equipped_items:=[]
	if weapon_node.get_child_count()>0:
		var weapon_item:=weapon_node.get_child(0)
		equipped_items.append(weapon_item)
	
	if shield_node.get_child_count()>0:
		var shield_item:=shield_node.get_child(0)
		equipped_items.append(shield_item)
		
	if armor_node.get_child_count()>0:
		var armor_item:=armor_node.get_child(0)
		equipped_items.append(armor_item)
		
	return equipped_items

func cache_item(item:ItemIcon,storage_node:Control):
	if(item==null):
		return
	item.get_parent().remove_child(item)
	storage_node.add_child(item)
