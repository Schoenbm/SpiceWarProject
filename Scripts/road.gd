extends Line2D



class_name Road
var current_ships_number = 0
@export var max_capacity = 50

@export var planet1 : Planet
@export var planet2 : Planet

@export var flow_rate : float
var flow_cd_planet1 = 0
var flow_cd_planet2 = 0

const my_scene: PackedScene = preload("res://Assets/Prefab/road.tscn")


static func create_road(P1: Planet, P2: Planet) -> Road :
	var new_road : Road = my_scene.instantiate()
	new_road.planet1 = P1
	new_road.planet2 = P2
	
	new_road.add_point(P1.global_position)
	new_road.add_point(P2.global_position)
	
	new_road.name = P1.name + "2" + P2.name
	return new_road

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta : float) -> void:
	if(flow_cd_planet1>0):
		flow_cd_planet1-= delta
	if(flow_cd_planet2>0):
		flow_cd_planet2-= delta
	

#renvoie true si le ship est bien enboyé
func send_ship(sender : Planet) -> bool:
	if(check_flow_rate_by_planet(sender) && 	current_ships_number <= max_capacity): # Road full et débit ok? 
		current_ships_number+=1
		var destination : Planet
		if(sender == planet1):
			destination = planet2
		else:
			destination = planet1
		var new_ship = Ship.create_ship(destination,sender)
		new_ship.name = "ship" + PlanetType.get_alliance_name(sender.alliance) + str(current_ships_number) #TODO EURK
		add_child(new_ship)
		put_flow_on_cd(sender)
		return true
	return false



func put_flow_on_cd(planet : Planet):
	if(planet == planet1):
		flow_cd_planet1 = flow_rate
	else:
		flow_cd_planet2 = flow_rate

func check_flow_rate_by_planet(planet : Planet) -> bool:
	if(planet == planet1):
		return(flow_cd_planet1 <= 0)
	return(flow_cd_planet2 <= 0)

func check_road_full() -> bool:
	return current_ships_number <= max_capacity

func get_current_ships(alliance:) -> int:
		return current_ships_number

func remove_ship():
	current_ships_number -= 1
