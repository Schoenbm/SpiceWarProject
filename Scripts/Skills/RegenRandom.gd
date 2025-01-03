extends Skill

class_name RegenRandom

var planet : Generator

@export var time : float
@export var ship_production_boost : float
@export var probability_boost : float
@export var send_ship_boost : float

func use_skill(aPlanet : Planet) -> void:
	planet = aPlanet
	planet.get_tree().create_timer(time).timeout.connect(_on_timeout)
	planet.acceleration_ships *= ship_production_boost
	planet.change_cooldown_ships( planet.send_ship_cd / send_ship_boost)
	planet.send_random = true
	planet.skill_in_use(true)
	planet.enable_ship_timer(true)
	planet.probability_ionization *= probability_boost


func _on_timeout():
	planet.acceleration_ships = planet.acceleration_ships / ship_production_boost
	planet.change_cooldown_ships( planet.send_ship_cd * send_ship_boost)
	planet.send_random = false
	planet.skill_in_use(false)
	planet.enable_ship_timer(true)
	planet.probability_ionization /= probability_boost
