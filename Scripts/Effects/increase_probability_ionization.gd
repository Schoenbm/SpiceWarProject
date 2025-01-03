extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[float]

func apply_effect(planet : Planet, tier : int):
	if(planet.type == PlanetData.Types.GENERATOR):
		planet.probability_ionization(values[tier])

func get_effect_description(tier) -> String:
	return effect_description + str(values[tier]) + " -> " + str(values[tier+1])
