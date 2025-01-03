extends Resource

class_name Upgrade

@export var effect_description : String

func apply_effect(planet : Planet, tier : int):
	pass


func get_effect_description(tier) -> String:
	return effect_description

func get_string(tier : int):
	if(tier >= 3):
		return ""
	else:
		return get_effect_description(tier)

func use(planet : Planet, tier : int):
	if(tier < 3):
		apply_effect(planet, tier)
