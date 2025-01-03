extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var values :  Array[float]

func apply_effect(planet : Planet, tier : int):
	planet.ship_speed_production = values[tier]

func get_effect_description(tier) -> String:
	return effect_description + str(values[tier]) + " -> " + str(values[tier+1])
