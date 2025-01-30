extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[int]

func apply_effect(planet : Planet, tier : int):
	print(planet.name + str(planet.skill))
	if(planet.type == PlanetData.Types.ACCELERATOR):
		planet.skill.range = values[tier]
		planet.base_skill.range = values[tier]
		planet.upgraded_skill.range = values[tier]
		return true
	return false

func get_effect_description(tier , player : Player = null) -> String:
	return effect_description + str(values[tier]) + " -> " + str(values[tier+1])
