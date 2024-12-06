extends Node2D

var player : Player 
var number_players

signal set_player(player)
signal player_win

var planets
var roads


var number_planets : int
var number_planets_by_alliance = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	planets = get_node("AllPlanets")
	roads = get_node("AllRoads")
	player = get_node("Player")
	number_planets = planets.get_child_count(false)
	number_players = 0
	number_planets_by_alliance[PlanetType.Alliance.NEUTRAL] = -10
	for planet in planets.get_children():
		planet.setup(player)
		if(number_planets_by_alliance.has(planet.alliance)):
			number_planets_by_alliance[planet.alliance] += 1
		else:
			number_players += 1
			number_planets_by_alliance[planet.alliance] = 1
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_planet_change_alliance(previous_alliance: Variant, current_alliance: Variant) -> void:
	number_planets_by_alliance[previous_alliance] -= 1
	number_planets_by_alliance[current_alliance] += 1

	if(number_planets_by_alliance[previous_alliance] <= 0):
		if(previous_alliance == player.alliance):
			print("u lost cringe dog")
		number_players -= 1
		if(number_players == 1 && current_alliance == player.alliance):
			print("u win u sly MONKEY")
