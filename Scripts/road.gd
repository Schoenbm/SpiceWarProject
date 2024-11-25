extends Line2D



class_name Road
@export var max_capacity = 3
var current_ships_number = 0

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
	if(current_ships_number < max_capacity):
		current_ships_number += 1
		sender.number_of_ships -= 1
		var destination : Planet
		if(sender == planet1):
			destination = planet2
		else:
			destination = planet1
		var new_ship = Ship.create_ship(destination,sender)
		new_ship.name = "ship" + str(current_ships_number)
		add_child(new_ship)

func remove_ship() :
	current_ships_number -= 1
