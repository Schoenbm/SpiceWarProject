extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[int]


func apply_effect(planet : Planet, tier : int):
	if(planet is Rafinery):
		planet.free_production = values[tier]
		return true
	return false


func get_effect_description(tier , player : Player = null) -> String:
	return effect_description + str(100/values[tier]) +"%" + " -> " + str(100/values[tier+1]) + "%"
