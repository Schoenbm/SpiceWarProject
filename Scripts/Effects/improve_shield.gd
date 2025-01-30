extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var scale_values :  Array[float]
@export var max_capacity_values :  Array[float]
@export var regen_values : Array[float]
@export var effect_description_2 : String
@export var effect_description_3 : String
func apply_effect(planet : Planet, tier : int):
	planet.set_shield(scale_values[tier], max_capacity_values[tier], regen_values[tier])
	return true

func get_effect_description(tier , player : Player = null) -> String:
	return effect_description + str(scale_values[tier]) + " -> " + str(scale_values[tier+1]) \
		+"\n" + effect_description_2 + str(max_capacity_values[tier]) + " -> " + str(max_capacity_values[tier+1]) \
		+"\n" + effect_description_3 + str(regen_values[tier]) + " -> " + str(regen_values[tier+1])
