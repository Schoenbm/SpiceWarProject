extends Skill

class_name EmptySkill


var planet : Planet

var prod : float 
@export var boost : float
@export var slow : float

func use_skill(aPlanet : Planet) -> void:
	planet = aPlanet
	planet.change_cooldown_ships( planet.send_ship_cd / boost)
	planet.acceleration_ships
	planet.send_all = true
	planet.acceleration_ships /= slow
	planet.skill_in_use(true)
	planet.enable_ship_timer(true)
	prod = planet.ship_speed_production
	planet.ship_speed_production = 0
	var time = planet.send_ship_cd * boost * ((planet.number_of_ships / planet.roads.size()) + 2)
	print("time = " + str(time))
	planet.get_tree().create_timer(time).timeout.connect(_on_timeout)
	


func _on_timeout():
	planet.change_cooldown_ships( planet.send_ship_cd * boost)
	planet.send_all = false
	planet.skill_in_use(false)
	planet.enable_ship_timer(true)
	planet.ship_speed_production = prod
	planet.acceleration_ships *= slow
