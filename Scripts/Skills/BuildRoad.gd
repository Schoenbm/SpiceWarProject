extends Skill

class_name BuildRoad

@export var range : int

func use_skill(aPlanet : Planet) -> void:
	aPlanet.player.enable_preroad(range)
	
