extends Area2D

class_name Ship

var speed = 100
var sending_planet : Planet
var destination_planet : Planet
var direction : Vector2
const my_scene : PackedScene = preload("res://Assets/Prefab/ship.tscn")

var alliance : PlanetType.Alliance

var stop_moving
var lifetime_particles : float 

static func create_ship(destination : Planet, sender : Planet) -> Ship:
	var new_ship = my_scene.instantiate()
	new_ship.sending_planet = sender
	new_ship.destination_planet = destination
	new_ship.direction = (destination.global_position - sender.global_position).normalized()
	new_ship.alliance = sender.alliance
	new_ship.speed =  new_ship.speed * sender.acceleration_ships
	new_ship.stop_moving = false
	return new_ship
	
func _process(delta: float) -> void:
	if(!stop_moving):
		translate(delta * direction * speed)
	
func _ready() -> void:
	global_position = sending_planet.global_position
	look_at(destination_planet.global_position)
	$ShipParticles.modulate = PlanetType.get_alliance_color(sending_planet.alliance)
	$ShipSprite.self_modulate = PlanetType.get_alliance_color(sending_planet.alliance)
	lifetime_particles = max($ShieldParticles.lifetime, $ShipParticles.lifetime, $PlanetParticles.lifetime)

#PLANETE OU SHIP DETECTE
func _on_area_entered(area: Area2D) -> void:
	if (area == destination_planet && alliance == destination_planet.alliance):
		destination_planet.addShip()
		destroy("")
	elif(area == destination_planet) : #Enemy planet 
		destination_planet.hit(alliance)
		destroy("planet")
	elif(area.has_method("create_ship") && area.alliance != self.alliance): # vaisseau enemi
		destroy("ship")
	elif(area.has_method("reboot") && area.activated && area.alliance != self.alliance): #shield
		area.hit(1)
		destroy("shield")
		
func destroy(particules : String ) -> void :
		get_parent().remove_ship()
		match particules :
			"planet":
				$ShipParticles.emitting = true
				$PlanetParticles.modulate = PlanetType.alliances_colors[destination_planet.alliance]
				$PlanetParticles.emitting = true
				await desactive_ship()
			"shield":
				$ShipParticles.emitting = true
				$ShieldParticles.emitting = true
				await desactive_ship()
			"ship":
				$ShipParticles.emitting = true
				await desactive_ship()
			"_":
				pass
	
		queue_free()

func desactive_ship() -> void:
		$ShipSprite.hide()
		$CollisionShape2D.disabled
		stop_moving = true
		collision_layer = 0
		collision_mask = 0
		await get_tree().create_timer(lifetime_particles).timeout


func change_planet(new_planet):
	if(new_planet.name == sending_planet.name):
		sending_planet = new_planet
	else:
		destination_planet = new_planet
