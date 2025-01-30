extends Planet

class_name Generator

@export var probability_ionization : float
 
var tier

func produce_ships(delta: float) -> void:
	current_ship_production += delta * ship_speed_production
	if(current_ship_production >= 1):
		if(randf() <= probability_ionization):
			ionize_ship()
			
		number_of_ships += 1
		current_ship_production -=1
