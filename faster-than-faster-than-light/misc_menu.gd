extends Control


@onready var main: Node = get_node("/root/Space")
@onready var ui: Node = get_node("/root/Space/CanvasLayer/UserInterface")


func left_button(weapon_index: int):
	if len(Global.fleet_inventory) > 0:
		var edited_ship: Node = main.get_node("FriendlyShips").get_child(ui.looking_at_ship_info)
		Global.fleet_inventory.insert(0, edited_ship.weapons[weapon_index])
		edited_ship.weapons[weapon_index] = Global.fleet_inventory.pop_back()


func right_button(weapon_index: int):
	if len(Global.fleet_inventory) > 0:
		var edited_ship: Node = main.get_node("FriendlyShips").get_child(ui.looking_at_ship_info)
		Global.fleet_inventory.append(edited_ship.weapons[weapon_index])
		edited_ship.weapons[weapon_index] = Global.fleet_inventory.pop_front()
