@tool
extends Node2D

@export var buildRoad : bool:
	set(value):
		buildRoad = false
		build_road()
		
@export var buildRoadsOnP1 : bool:
	set(value):
		buildRoadsOnP1 = false
		build_roads_on_one()

@export var buildAllRoads : bool:
	set(value):
		erase_roads()
		buildAllRoads = false
		build_roads()

@export var eraseAllRoads : bool:
	set(value):
		eraseAllRoads = false
		erase_roads()
@export var printPlanetsRN : bool:
	set(value):
		printPlanetsRN = false
		print_planets_neighbors()

@export var roads : Node2D
@export var planets : Node2D
@export var planet1 : Planet
@export var planet2 : Planet

@export var _set_ids : bool:
	set(value):
		_set_ids = false
		set_ids()
		
func set_ids():
	var p_id : int
	for planet in planets.get_children():
		if planet is Planet:
			planet.set_planet_id(p_id);
		print("planet name id =" + str(p_id))
		p_id += 1
	
func build_roads():
	set_ids()
	for planet in planets.get_children():
		if planet is Planet:
			setup_planet(planet);

func print_planets_neighbors():
	for planet in planets.get_children():
		if planet is Planet:
			print(planet.name + " neighbors : " + str(planet.neighbors))
			print(" roads : " + str(planet.roads))
			
func erase_roads():
	for node in planets.get_children():
		if node is Road:
			node.queue_free()

		if node is Planet:
			node.clean_neighbors()
	for road in roads.get_children():
		road.queue_free()
	for road in get_tree().get_nodes_in_group("Road"):
		road.queue_free()
	print("clean over")

func  setup_planet(p : Planet):
	p.build_roads()

		
func build_road():
	planet1.make_road(planet2)
	
func build_roads_on_one():
	set_ids()
	planet1.build_roads()
