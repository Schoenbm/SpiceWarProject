extends "res://Assets/Resources/technology_effect/Upgrade.gd"

@export var bonus_damage : int

func apply_effect(planet : Planet, tier : int):
	if(tier == 3):
		planet.bonus_damage_ionized_ships = bonus_damage
		return true
	return false

func get_effect_description(tier, player : Player = null) -> String:
	if(tier == 2):
		return effect_description
	return ""
