extends Resource

class_name Upgrade

@export var effect_description : String

@export var on_player : bool
@export var type : PlanetData.Types

func apply_effect(planet : Planet, tier : int) ->bool:
	return false


func get_effect_description(tier, player : Player = null) -> String:
	return effect_description

func get_string(tier : int, player : Player = null):
	if(tier >= 3):
		return ""
	elif player == null:
		return get_effect_description(tier)
	else:
		return get_effect_description(tier, player)

func use(planet : Planet = null, tier : int  = 0, player : Player = null) -> bool:
	if(tier <= 3 && !on_player && planet != null && (type == PlanetData.Types.NORMAL || type == planet.type)):
		return apply_effect(planet, tier)
		
	elif(on_player && player != null):
		apply_effect_on_player(player)
	return false
	
func apply_effect_on_player(player):
	pass
