extends Area2D

class_name Ship

const speed = 100
var sendingPlanet : Planet
var destinationPlanet : Planet
var direction : Vector2
const my_scene : PackedScene = preload("res://Assets/Prefab/ship.tscn")

static func create_ship(destination : Planet, sender : Planet) -> Ship:
	var new_ship = my_scene.instantiate()
	new_ship.sendingPlanet = sender
	new_ship.destinationPlanet = destination
	new_ship.direction = (destination.global_position - sender.global_position).normalized()
	return new_ship
	
func _process(delta: float) -> void:
	translate(delta * direction * speed)
	$AnimatedSprite2D.play()
	
func _ready() -> void:
	global_position = sendingPlanet.global_position


func _on_area_entered(area: Area2D) -> void:
	if (area == destinationPlanet):
		if(destinationPlanet.addShip()):
			get_parent().remove_ship()  #TODO CEST BEAUCOU TROP YOLO CHANGER CA
			queue_free()
		else:
			var temp_planet : Planet
			temp_planet = sendingPlanet
			sendingPlanet = destinationPlanet
			destinationPlanet = temp_planet
			direction = -1 * direction
