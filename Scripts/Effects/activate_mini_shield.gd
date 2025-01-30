extends "res://Assets/Resources/technology_effect/Upgrade.gd"


func apply_effect(planet : Planet, tier : int):
	if(tier == 3):
		if(planet is Defensive):
			planet.mini_shield = true
			return true
	else:
		if(planet is Defensive):
			planet.mini_shield = false
	return false
	
func get_effect_description(tier , player : Player = null) -> String:
	if(tier == 2):
		return effect_description
	return ""
