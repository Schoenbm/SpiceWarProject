extends Line2D



class_name Road
@export var max_capacity = 3
var current_ships_number_alliance1 = 0
var current_ships_number_alliance2 = 0

@export var planet1 : Planet
@export var planet2 : Planet


const my_scene: PackedScene = preload("res://Assets/Prefab/road.tscn")


static func create_road(P1: Planet, P2: Planet) -> Road :
	var new_road : Road = my_scene.instantiate()
	new_road.planet1 = P1
	new_road.planet2 = P2
	new_road.max_capacity = 3
	
	new_road.add_point(P1.global_position)
	new_road.add_point(P2.global_position)
	
	new_road.name = P1.name + "2" + P2.name
	return new_road

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func send_ship(sender : Planet) -> void:
	if(check_road_full_by_alliance(sender.alliance)):
		incr_ships_number_by_alliance(sender.alliance)
		sender.number_of_ships -= 1
		var destination : Planet
		if(sender == planet1):
			destination = planet2
		else:
			destination = planet1
		var new_ship = Ship.create_ship(destination,sender)
		new_ship.name = "ship" + PlanetType.get_alliance_name(sender.alliance) + str(get_current_ships_number_by_alliance(sender.alliance)) #TODO EURK
		add_child(new_ship)


#TODO IMRPOVE ?
func remove_ship_by_alliance(alliance: PlanetType.Alliance) -> void:
	if(alliance == planet1.alliance):
		current_ships_number_alliance1 -= 1
	else:
		current_ships_number_alliance2 -= 1
		
	
func incr_ships_number_by_alliance(alliance: PlanetType.Alliance) -> void:
	if(alliance == planet1.alliance):
		current_ships_number_alliance1 += 1
	else:
		current_ships_number_alliance2 += 1
		
func check_road_full_by_alliance(alliance: PlanetType.Alliance) -> bool:
	if(alliance == planet1.alliance):
		return current_ships_number_alliance1 <= max_capacity
	else:
		return current_ships_number_alliance2 <= max_capacity
		
func get_current_ships_number_by_alliance(alliance: PlanetType.Alliance) -> int:
	if(alliance == planet1.alliance):
		return current_ships_number_alliance1
	else:
		return current_ships_number_alliance2
