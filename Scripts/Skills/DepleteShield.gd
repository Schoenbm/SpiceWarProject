extends Skill

class_name DepleteShield


var planet : Planet

var shield : Shield 
var original_regen : float
@export var delay_rate : float

func use_skill(aPlanet : Planet) -> void:
	planet = aPlanet
	shield = planet.shield

	planet.skill_in_use(true)
	original_regen = shield.shield_regen_delay
	shield.shield_regen_delay = 10000
	planet.get_tree().create_timer(delay_rate).timeout.connect(_on_timeout)
	


func _on_timeout():
	if(!make_ship() || shield.shield_capacity == 0):
		planet.skill_in_use(false)
		shield.shield_regen_delay = original_regen
	else: 
		planet.get_tree().create_timer(delay_rate).timeout.connect(_on_timeout)

func make_ship() -> bool:
	shield.deplete_energy(1)
	return(planet.ionize_ship())
