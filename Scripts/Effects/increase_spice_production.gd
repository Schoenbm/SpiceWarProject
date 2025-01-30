extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[float]

func apply_effect(planet : Planet, tier : int):
	if(planet.type == PlanetData.Types.RAFINERY):
		planet.spice_production_speed = values[tier]
		return true
	return false

func get_effect_description(tier , player : Player = null) -> String:
	return effect_description + str(values[tier]) + " -> " + str(values[tier+1])
