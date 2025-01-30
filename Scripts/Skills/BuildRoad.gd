extends Skill

class_name BuildRoad

@export var range : int
@export var bonus_range = 0

func use_skill(aPlanet : Planet) -> void:
	aPlanet.player.enable_preroad(range + bonus_range)
	
