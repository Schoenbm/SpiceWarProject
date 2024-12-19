extends Skill

class_name RegenRandom

var planet : Planet

@export var time : float
@export var boost : float

func use_skill(aPlanet : Planet) -> void:
	planet = aPlanet
	planet.get_tree().create_timer(time).timeout.connect(_on_timeout)
	planet.acceleration_ships *= boost
	planet.change_cooldown_ships( planet.send_ship_cd / boost)
	planet.send_random = true
	planet.skill_in_use(true)
	planet.enable_ship_timer(true)


func _on_timeout():
	planet.acceleration_ships = planet.acceleration_ships / boost
	planet.change_cooldown_ships( planet.send_ship_cd * boost)
	planet.send_random = false
	planet.skill_in_use(false)
	planet.enable_ship_timer(true)
