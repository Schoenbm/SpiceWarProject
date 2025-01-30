extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[float]

func apply_effect(planet : Planet, tier : int):
		planet.set_durability_ionized_ships(values[tier])
		return values[tier] != values[tier - 1]

func get_effect_description(tier, player : Player = null) -> String:
	if(tier == 2):
		return effect_description + str(values[2]) + "->" + str(values[3])
	return ""
