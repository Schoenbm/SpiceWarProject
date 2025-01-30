extends "res://Assets/Resources/technology_effect/Upgrade.gd"

func apply_effect(planet : Planet, tier : int):
	planet.upgrade_skill(tier == 3)
	return tier == 3

func get_effect_description(tier , player : Player = null) -> String:
	if(tier == 2):
		return effect_description
	return ""
