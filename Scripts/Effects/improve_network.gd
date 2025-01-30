extends Upgrade

@export var flowrate_values :  Array[float]
@export var production_speed_values :  Array[float]

@export var effect_description_2 : String

func apply_effect(planet : Planet, tier : int):
	planet.network_flowrate_bonus = flowrate_values[tier]
	planet.network_production_bonus = production_speed_values[tier]
	planet.change_cooldown_ships()
	return true

func get_effect_description(tier , player : Player = null) -> String:
	return effect_description + str(flowrate_values[tier]) + " -> " + str(flowrate_values[tier+1]) \
		+"\n" + effect_description_2 + str(production_speed_values[tier]) + " -> " + str(production_speed_values[tier+1])
