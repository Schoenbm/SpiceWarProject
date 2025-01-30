extends Node2D

class_name Player

var player_name = ""
var alliance = PlanetType.Alliance.RED

var technology_tiers = {}

var player_id : int
var player_input = {}

var gm : GameManager
# Called when the node enters the scene tree for the first time.
func setup_player(game_manager : GameManager) -> void:
	gm = game_manager
	var branch_value
	for branch in PlanetData.Types:
		branch_value = PlanetData.Types[branch]
		technology_tiers[branch_value] = 0
	self.add_to_group("network_sync")
	preparePlayer()
	pass # Replace with function body.

func tier_upgrade(tech_branch : PlanetData.Types):
	technology_tiers[tech_branch] += 1
	gm.upgrade_tiers(alliance, tech_branch)

func get_tier(tech_branch : PlanetData.Types):
	return technology_tiers[tech_branch]

	
func _network_process(input : Dictionary):
	gm.action(input)

func upgrade_tier(tech_branch : PlanetData.Types):
	technology_tiers[tech_branch] += 1

func init(pd : PlayerData):
	player_name = pd.player_name
	alliance = pd.player_alliance
	player_id = pd.player_id
	name = pd.player_name + str(pd.player_id)
	
func preparePlayer():
	pass


func _get_local_input() -> Dictionary:
	var new_input = player_input.duplicate()
	player_input.clear()
	return new_input
	

func input_attack_planet(id_attacker : int, id_defender : int):
	player_input["attack"] = [id_attacker, id_defender]

func input_upgrade_planet(id_planet : int, id_branch : int):
	player_input["upgrade"] = [id_planet, id_branch]

func input_skill(id_planet : int, id_target_planet  : int = -1):
	player_input["skill"] = [id_planet, id_target_planet]

func input_research(id_planet : int , id_branch : int):
	player_input["research"] = [id_planet, id_branch]
	
func _predict_remote_input(previous_input : Dictionary, ticks : int) -> Dictionary:
	return {}
	
