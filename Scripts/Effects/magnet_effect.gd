extends "res://Assets/Resources/technology_effect/Upgrade.gd"


func apply_effect(planet : Planet, tier : int):
	planet.magnet = (tier == 3)
