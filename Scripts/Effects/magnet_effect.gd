extends "res://Assets/Resources/technology_effect/Upgrade.gd"


func apply_effect(planet : Planet, tier : int):
	planet.magnet = (tier == 3)


func get_effect_description(tier , player : Player = null) -> String:
	if(tier == 2):
		return effect_description
	else:
		return ""
