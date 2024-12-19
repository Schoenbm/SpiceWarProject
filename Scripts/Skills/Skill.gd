extends Resource

class_name Skill

@export var spice_cost : float

func use_skill(planet : Planet) -> void:
	print("planet use skill")  

func buy_skill(spice_quantity : int) -> bool:
	return spice_quantity >= spice_cost
