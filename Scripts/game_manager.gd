extends Node2D

class_name GameManager

var local_player : LocalPlayer 
var number_players
var players : Dictionary
signal set_player(local_player)
signal player_win

var planets_node 
var planets : Dictionary
var planets_by_alliance : Dictionary

var roads

var PLANET_DATA  = load("res://Assets/Resources/PlanetData.tres")

const planet_prefab : PackedScene = preload("res://Assets/Prefab/Planets/planet.tscn")
const defensive_planet_prefab : PackedScene = preload("res://Assets/Prefab/Planets/defensive_planet.tscn")
const generator_prefab : PackedScene = preload("res://Assets/Prefab/Planets/generator.tscn")
const accelerator_prefab : PackedScene = preload("res://Assets/Prefab/Planets/acceleration_planet.tscn")
const laboratory_prefab : PackedScene = preload("res://Assets/Prefab/Planets/laboratory.tscn")
const rafinery_prefab : PackedScene = preload("res://Assets/Prefab/Planets/rafinery.tscn")

const player_prefab : PackedScene = preload("res://Assets/Prefab/player.tscn")

@export var accelerator_research_effects : Array[Upgrade]
@export var generator_research_effects : Array[Upgrade]
@export var rafinery_research_effects : Array[Upgrade]
@export var shield_research_effects : Array[Upgrade]
@export var laboratory_research_effects : Array[Upgrade]

	
@export var accelerator_cost : Array[Cost]
@export var generator_cost : Array[Cost]
@export var rafinery_cost : Array[Cost]
@export var shield_cost : Array[Cost]
@export var laboratory_cost : Array[Cost]

var research_dict = {}

var research_cost_dict = {}


signal local_player_setup(LocalPlayer)
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	planets_node = get_node("AllPlanets")
	roads = get_node("AllRoads")
	init_dict()
	if(!MultiplayerManager.solo):
		setup_multiplayer()
	else:
		setup_solo()
	setup_players()
	setup_planets()
	MultiplayerManager.player_loaded()


func _on_planet_change_alliance(planet : Planet, current_alliance: Variant) -> void:
	var previous_alliance = planet.alliance
	planets_by_alliance[previous_alliance].erase(planet.name)
	planets_by_alliance[current_alliance][planet.name] = planet
	if(current_alliance == local_player.alliance):
		reset_planet_upgrades_to_player(local_player, planet)
	print("alliance_change")
	if(planets_by_alliance[previous_alliance].is_empty()):
		if(previous_alliance == local_player.alliance):
			print("u lost cringe dog")
		number_players -= 1
		if(number_players <= 1 && current_alliance == local_player.alliance):
			print("u win u sly MONKEY")

func get_planet_close_to(origin_planet, radius):
	var close_planets : Array[Planet]
	for planet in planets.values():
		if(planet is Planet && planet.position.distance_to(origin_planet.position) < radius):	
			close_planets.append(planet)
	return close_planets

func update_planets(planet):
	if planets.has(planet.planet_id):
		planets.erase(planet.planet_id)
		planets[planet.planet_id] = planet
		
		planets_by_alliance[planet.alliance].erase(planet.planet_id)
		planets_by_alliance[planet.alliance][planet.planet_id] = planet
		
		planet.self_updated.connect(_on_planet_self_updated)
		print("update completed")
	else:
		print(planet.name)

func try_upgrade(cost : int, planet_type : PlanetData.Types, planet : Planet) -> bool:
	if(planet.number_of_ships >= cost):
		planet.reduce_ships_number(cost)
		var new_planet : Planet
		match planet_type :
			PlanetData.Types.GENERATOR : new_planet = generator_prefab.instantiate()
			PlanetData.Types.DEFENSIVE : new_planet = defensive_planet_prefab.instantiate()
			PlanetData.Types.ACCELERATOR : new_planet = accelerator_prefab.instantiate()
			PlanetData.Types.RAFINERY : new_planet = rafinery_prefab.instantiate()
			PlanetData.Types.NORMAL : new_planet = planet_prefab.instantiate()
			PlanetData.Types.LABORATORY : new_planet = laboratory_prefab.instantiate()
			"_" : 
				print("names dont match") 
				return false
		planet.transform_planet(new_planet)
		return true
	return false
	
func _on_planet_self_updated(planet: Planet) -> void:
	update_planets(planet)
	reset_planet_upgrades_to_player(local_player, planet)

func reset_planet_upgrades_to_player(local_player : Player ,planet : Planet):
	var tier = 0
	for branch in research_dict:
		tier = local_player.get_tier(branch)
		for upgrade in research_dict[branch]:
			if(!upgrade.on_player):
				upgrade.use(planet,tier)


func upgrade_tier(alliance, tech_branch):
	if(tech_branch == PlanetData.Types.NORMAL):
		return
		
	local_player.upgrade_tier(tech_branch)	
	var tier = local_player.get_tier(tech_branch)

	for upgrade in research_dict[tech_branch]:
		if(upgrade.on_player):
			upgrade.use(null,tier,local_player)
		else:
			for planet in planets_by_alliance[alliance].values():
				print(planet.name)
				if(upgrade.use(planet,tier)):
					planet.particles_effect()
				
#TODO Quasi meme fonction que CAN AFFORD
func buy_upgrade_tier(p_player : Player, tech_branch : PlanetData.Types, planet : Planet) -> bool:
	var tier = p_player.get_tier(tech_branch)
	var spice_cost = research_cost_dict[tech_branch][tier].spice_cost
	var ship_cost = research_cost_dict[tech_branch][tier].ship_cost
	if(local_player.spices >= spice_cost && planet.number_of_ships >= ship_cost):
		local_player.spices -= spice_cost
		planet.reduce_ships_number(ship_cost)
		return true
	return false

func get_branch_cost_and_effect(p_player : Player, tech_branch : PlanetData.Types):
	var tier = p_player.get_tier(tech_branch)
	if(tier == 3):
		return
	
	var values : Array[String]
	values.append(str(research_cost_dict[tech_branch][tier].spice_cost))
	values.append(str(research_cost_dict[tech_branch][tier].ship_cost))
	values.append(str(research_cost_dict[tech_branch][tier].time_cost))
	
	var strings = [] # Une liste temporaire pour stocker les chaînes
	for upgrade in research_dict[tech_branch]:
		var str = upgrade.get_string(tier, local_player)
		if str != "":
			strings.append(str)
	
	values.append("\n".join(strings))
	return values

func can_afford_research(p_player : Player, tech_branch : PlanetData.Types, planet : Planet):
	var tier = p_player.get_tier(tech_branch)
	if(tier > 2):
		return false
	var spice_cost = research_cost_dict[tech_branch][tier].spice_cost
	var ship_cost = research_cost_dict[tech_branch][tier].ship_cost
	if(local_player.spices >= spice_cost && planet.number_of_ships >= ship_cost):
		return true
	return false

func set_alliance(planet : Planet):
	if(planet.starter_player > players.size()):
		create_bot(planet.starter_player, planet.starter_player-1)
	var vplayer : Player = players[planet.starter_player] as Player
	planet.set_alliance(vplayer.alliance, true)
	if(planet.starter_player == LocalPlayerData.player_id):
		pass#local_player.camera.position = planet.position

func start_game():
	for planet in planets.values():	
		planet.boot()


func _on_stop_match_pressed() -> void:
	MultiplayerManager.stop_match()

func init_dict():
	research_dict[PlanetData.Types.ACCELERATOR] = accelerator_research_effects
	research_dict[PlanetData.Types.GENERATOR] = generator_research_effects
	research_dict[PlanetData.Types.RAFINERY] = rafinery_research_effects
	research_dict[PlanetData.Types.DEFENSIVE] = shield_research_effects
	research_dict[PlanetData.Types.LABORATORY] = laboratory_research_effects
	
	research_cost_dict[PlanetData.Types.ACCELERATOR] = accelerator_cost
	research_cost_dict[PlanetData.Types.GENERATOR] = generator_cost
	research_cost_dict[PlanetData.Types.RAFINERY] = rafinery_cost
	research_cost_dict[PlanetData.Types.DEFENSIVE] = shield_cost
	research_cost_dict[PlanetData.Types.LABORATORY] = laboratory_cost

func setup_multiplayer():
	MultiplayerManager.game_loaded.connect(start_game)
	for player_data in MultiplayerManager.players.values():
		var peer_id = MultiplayerManager.players.find_key(player_data)
		if(player_data.player_id == LocalPlayerData.player_id):
			local_player = player_prefab.instantiate()
			print("i have a local player" + str(local_player.name))
			local_player.init(LocalPlayerData)
			players[player_data.player_id] = local_player
		else:
			var new_player = Player.new()
			new_player.init(player_data)
			players[player_data.player_id] = new_player
		players[player_data.player_id].set_multiplayer_authority(peer_id)
		add_child(players[player_data.player_id])
	number_players = players.size()
	
func setup_solo():
	players[0] = player_prefab.instantiate()
	players[0].init(LocalPlayerData)
	add_child(players[0])
	for i in range(1,3):
		create_bot(i,i-1)
	
	number_players = players.size()

func create_bot(index : int, alliance : int):
	players[index] = Player.new()
	players[index].player_name = "bob"
	players[index].alliance = PlanetType.get_alliance_from_int(alliance)
	add_child(players[index])
	
func setup_planets():
	var planet_id = 0
	for planet in planets_node.get_children():
		planet.set_planet_id(planet_id)
		planets[planet_id] = planet
		planet_id += 1
	for planet in planets_node.get_children():
		planet.set_physics_process(MultiplayerManager.solo)

		planet.setup(local_player)
		planet.self_updated.connect(_on_planet_self_updated)
		planet.change_alliance.connect(_on_planet_change_alliance)
		if(planet.starter_player != 0):
			set_alliance(planet)
		if(!planets_by_alliance.has(planet.alliance)):
			planets_by_alliance[planet.alliance] = {}
		planets_by_alliance[planet.alliance][planet.planet_id] = planet
		if(planet.alliance != PlanetType.Alliance.NEUTRAL):
			reset_planet_upgrades_to_player(local_player, planet)

func get_planet(id):
	return planets[id]

func setup_players():
	for player in players.values():
		player.setup_player(self)
	local_player_setup.emit(local_player)

func _save_state():
	var state = {}
	for player in players.values():
		state[player.player_id] = {
			"alliance" : player.alliance,
			"tiers" : player.technology_tiers,
			"player_name" : player.player_name
		}
	return state


func _load_state(state : Dictionary):
	for player in players.values():
		player.alliance = state[player.player_id]["alliance"]
		player.technology_tiers = state[player.player_id]["tiers"]
		player.player_name = state[player.player_id]["player_name"]

func get_planets_from_planets_id(planets_id : Array) -> Dictionary:
	var vplanets = {}
	for vplanet_id in planets_id:
		vplanets[vplanet_id] = planets[vplanet_id]
	return vplanets

func action(input : Dictionary):
	if(input.size() > 0):
		print(str(SyncManager._current_tick) + str(input))
	if(input.has("upgrade")):
		var up_type = PlanetData.Types[input["upgrade"][1]]
		var up_planet = planets[input["upgrade"][0]]
		if(up_planet.type == up_type):
			try_upgrade(-PLANET_DATA.get_cost(up_type)/2,PlanetData.Types.NORMAL, up_planet)
		else :
			try_upgrade(PLANET_DATA.get_cost(up_type), up_type, up_planet)
	if(input.has("attack")):
		print("attacking")
		planets[input["attack"][0]].confirm_attack_on_planet(planets[input["attack"][1]])
	if(input.has("research")):
		pass
	if(input.has("skill")):
		pass
