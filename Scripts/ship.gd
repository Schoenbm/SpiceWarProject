extends Area2D

class_name Ship

const speed = 100
var sendingPlanet : Planet
var destinationPlanet : Planet
var direction : Vector2
const my_scene : PackedScene = preload("res://Assets/Prefab/ship.tscn")

var alliance : PlanetType.Alliance

static func create_ship(destination : Planet, sender : Planet) -> Ship:
	var new_ship = my_scene.instantiate()
	new_ship.sendingPlanet = sender
	new_ship.destinationPlanet = destination
	new_ship.direction = (destination.global_position - sender.global_position).normalized()
	new_ship.alliance = sender.alliance
	new_ship.modulate = PlanetType.get_alliance_color(sender.alliance)
	return new_ship
	
func _process(delta: float) -> void:
	translate(delta * direction * speed)
	
func _ready() -> void:
	global_position = sendingPlanet.global_position

#PLANETE OU SHIP DETECTE
func _on_area_entered(area: Area2D) -> void:
	if (area == destinationPlanet && alliance == destinationPlanet.alliance):
		if(destinationPlanet.addShip()): 
			destroy()
		else: # DEMI TOUR SI PLANETE PLEINE
			var temp_planet : Planet
			temp_planet = sendingPlanet
			sendingPlanet = destinationPlanet
			destinationPlanet = temp_planet
			direction = -1 * direction
	elif(area == destinationPlanet) : #Enemy planet 
		destinationPlanet.hit(alliance)
		destroy()
	elif(area.has_method("create_ship") && area.alliance != self.alliance): # vaisseau enemi
		destroy()
		
func destroy() -> void :
		get_parent().remove_ship_by_alliance(alliance)
		queue_free()
