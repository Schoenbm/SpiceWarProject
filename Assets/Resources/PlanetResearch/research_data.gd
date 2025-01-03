extends Resource
class_name ResearchData

enum TechnologyBranch{
	ACCELERATOR,
	GENERATOR,
	RAFINERY,
	SHIELD,
	NETWORK
}

@export var TechnologyBranch_name = {
	TechnologyBranch.ACCELERATOR: "accelerator",
	TechnologyBranch.GENERATOR: "generator",
	TechnologyBranch.RAFINERY: "rafinery",
	TechnologyBranch.SHIELD: "normal",
	TechnologyBranch.NETWORK : "defensive"
}

#INDEX 0 : SHIPS, INDEX 1 : SPICE, INDEX 2 : TIME
@export var TechnologyBranch_cost_tier1 = {
	TechnologyBranch.ACCELERATOR: [10,0,25],
	TechnologyBranch.GENERATOR: [10,0,25],
	TechnologyBranch.RAFINERY: [15,0,25],
	TechnologyBranch.SHIELD: [10,0,20],
	TechnologyBranch.NETWORK : [15,0,25]
}

@export var TechnologyBranch_cost_tier2 = {
	TechnologyBranch.ACCELERATOR: [20,10,30],
	TechnologyBranch.GENERATOR: [20,10,30],
	TechnologyBranch.RAFINERY: [20,10,30],
	TechnologyBranch.SHIELD: [15,5,30],
	TechnologyBranch.NETWORK : [20,15,30]
}
@export var TechnologyBranch_cost_tier3 = {
	TechnologyBranch.ACCELERATOR: [25,25,35],
	TechnologyBranch.GENERATOR: [30,25,35],
	TechnologyBranch.RAFINERY: [30,25,35],
	TechnologyBranch.SHIELD: [15,10,20],
	TechnologyBranch.NETWORK : [20,15,30]
}

#-----------------------------------------------------------------------
@export var TechnologyBranch_effects_tier1 = {
	TechnologyBranch.ACCELERATOR: "+ production speed \n + acceleration \n + spell range",
	TechnologyBranch.GENERATOR: "+ production speed  \n + ionized probability",
	TechnologyBranch.RAFINERY: "+ spice production \n - spell cooldown",
	TechnologyBranch.SHIELD: "+ shield size \n + shield capacity  \n - reboot time \n + shield regen",
	TechnologyBranch.NETWORK : "+ all production speed \n + all acceleration"
}

@export var TechnologyBranch_effects_tier2 = {
	TechnologyBranch.ACCELERATOR: "+ production speed \n + acceleration \n + spell range",
	TechnologyBranch.GENERATOR: "+ production speed \n + ionized probability",
	TechnologyBranch.RAFINERY: "+ spice production \n - spell cooldown \n + production efficiency" ,
	TechnologyBranch.SHIELD: "+ shield size \n + shield capacity  \n - reboot time \n + shield regen",
	TechnologyBranch.NETWORK :  "+ all production speed \n + all acceleration"
}
@export var TechnologyBranch_effects_tier3 = {
	TechnologyBranch.ACCELERATOR: "+ production speed \n + acceleration \n + spell range \n + magnet effect",
	TechnologyBranch.GENERATOR: "+ production speed \n + ionized damage \n + ionized probability \n + ionized survability",
	TechnologyBranch.RAFINERY: "+ spice production \n - spell cooldown \n  + production efficiency \n + improve spells",
	TechnologyBranch.SHIELD: "+ shield size \n + shield capacity  \n - reboot time \n + shield regen +\n mini shield",
	TechnologyBranch.NETWORK :  "+ all production speed \n + all acceleration"
}
func get_cost(planet_type, tier):
	if !(planet_type in TechnologyBranch):
		return -1
	
	match tier:
		_ : return null
		1 : return TechnologyBranch_cost_tier1[planet_type]
		2 : return TechnologyBranch_cost_tier2[planet_type]
		3 : return TechnologyBranch_cost_tier3[planet_type]

func get_effect(planet_type, tier):
	if !(planet_type in TechnologyBranch):
		return -1
	
	match tier:
		_ : return null
		1 : return TechnologyBranch_effects_tier3[planet_type]
		2 : return TechnologyBranch_effects_tier3[planet_type]
		3 : return TechnologyBranch_effects_tier3[planet_type]
