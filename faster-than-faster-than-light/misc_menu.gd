extends Control


@onready var main: Control = get_node("/root/Space")
@onready var ui: Control = get_node("/root/Space/CanvasLayer/UserInterface")
var inventory_weapons: Array
var inventory_drones: Array


func left_button(weapon_index: int) -> void:
	sort_inventory()
	var edited_ship: Node3D = main.get_node("FriendlyShips").get_child(ui.looking_at_ship_info)
	if edited_ship.type == 1 and len(inventory_weapons) > 0:
		inventory_weapons.insert(0, edited_ship.weapons[weapon_index])
		edited_ship.weapons[weapon_index] = inventory_weapons.pop_back()
	elif edited_ship.type == 7 and len(inventory_drones) > 0:
		inventory_drones.insert(0, edited_ship.drones[weapon_index])
		edited_ship.drones[weapon_index] = inventory_drones.pop_back()
	Global.fleet_inventory = inventory_weapons + inventory_drones
	ui.get_node("PressSFX").play()


func right_button(weapon_index: int) -> void:
	sort_inventory()
	var edited_ship: Node3D = main.get_node("FriendlyShips").get_child(ui.looking_at_ship_info)
	if edited_ship.type == 1 and len(inventory_weapons) > 0:
		inventory_weapons.append(edited_ship.weapons[weapon_index])
		edited_ship.weapons[weapon_index] = inventory_weapons.pop_front()
	elif edited_ship.type == 7 and len(inventory_drones) > 0:
		inventory_drones.append(edited_ship.drones[weapon_index])
		edited_ship.drones[weapon_index] = inventory_drones.pop_front()
	Global.fleet_inventory = inventory_weapons + inventory_drones
	ui.get_node("PressSFX").play()


func sort_inventory() -> void:
	inventory_weapons = []
	inventory_drones = []
	for item in Global.fleet_inventory:
		if Global.weapon_list[item]["Type"] < 3:
			inventory_weapons.append(item)
		else:
			inventory_drones.append(item)
