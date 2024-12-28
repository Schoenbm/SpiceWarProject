extends Node2D

var player : Player 
var number_players

signal set_player(player)
signal player_win

var planets_node
var planets : Dictionary
var roads


var number_planets : int
var number_planets_by_alliance = {}
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	planets_node = get_node("AllPlanets")
	roads = get_node("AllRoads")
	player = get_node("Player")
	number_planets = planets_node.get_child_count(false)
	number_players = 0
	number_planets_by_alliance[PlanetType.Alliance.NEUTRAL] = -10
	for planet in planets_node.get_children():
		planets[planet.name] = planet
		planet.setup(player)
		planet.self_updated.connect(_on_planet_self_updated)
		if(number_planets_by_alliance.has(planet.alliance)):
			number_planets_by_alliance[planet.alliance] += 1
		else:
			number_players += 1
			number_planets_by_alliance[planet.alliance] = 1
			


func _on_planet_change_alliance(previous_alliance: Variant, current_alliance: Variant) -> void:
	number_planets_by_alliance[previous_alliance] -= 1
	number_planets_by_alliance[current_alliance] += 1

	if(number_planets_by_alliance[previous_alliance] <= 0):
		if(previous_alliance == player.alliance):
			print("u lost cringe dog")
		number_players -= 1
		if(number_players == 1 && current_alliance == player.alliance):
			print("u win u sly MONKEY")

func get_planet_close_to(origin_planet, radius):
	var bol = false
	var close_planets : Array[Planet]
	for planet in planets.values():
		if(planet is Planet && planet.position.distance_to(origin_planet.position) < radius):	
			close_planets.append(planet)
	return close_planets

func update_planet(planet):
	if planets.has(planet.name):
		planets.erase(planet.name)
		planets[planet.name] = planet
		planet.self_updated.connect(_on_planet_self_updated)
		print("update completed")
	else:
		print(planet.name)


func _on_planet_self_updated(planet: Planet) -> void:
	update_planet(planet)
	print("planet updated in gm")
