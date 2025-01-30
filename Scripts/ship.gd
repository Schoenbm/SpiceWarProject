extends Area2D

class_name Ship

@export var speed = 100
@export var damage = 1
@export var shield_damage = 1

var sending_planet_id : int
var destination_planet_id : int
var direction : Vector2
const ship_scene : PackedScene = preload("res://Assets/Prefab/Ship/ship.tscn")
const ionized_scene : PackedScene = preload("res://Assets/Prefab/Ship/ionized_ship.tscn")
const shield_ship_scene : PackedScene = preload("res://Assets/Prefab/Ship/shield_ship.tscn")


@export var ionized = false
@export var shield = false
var alliance : PlanetType.Alliance

var stop_moving
var lifetime_particles : float 

static func spawn(data : Dictionary, road : Node2D , ionized : bool, shield_ship : bool, name : String):
	if(ionized):
		SyncManager.spawn(name,road, Ship.ionized_scene,data)
	elif(shield_ship):
		SyncManager.spawn(name,road, Ship.shield_ship_scene,data)	
	else:
		SyncManager.spawn(name, road, Ship.ship_scene,data)

func _network_spawn(data : Dictionary):
	if(ionized):
		shield_damage = data["ionized_bonus_damage"]
	sending_planet_id = data["sender"]
	destination_planet_id = data["destination"]
	direction = data["position"]
	alliance = data["alliance"]
	speed =  speed * data["acceleration_ships"]
	stop_moving = false
	global_position = data["position"]
	look_at(data["direction"] + global_position)
	direction = data["direction"]
	$ShipParticles.modulate = PlanetType.get_alliance_color(alliance)
	$ShipSprite.self_modulate = PlanetType.get_alliance_color(alliance)
	lifetime_particles = max($ShieldParticles.lifetime, $ShipParticles.lifetime, $PlanetParticles.lifetime)


#static func create_ship(destination : Planet, sender : Planet, pIonized : bool, pShieldShip : bool = false) -> Ship:
	#var new_ship
	#
	#if pIonized:
		#new_ship = ionized_scene.instantiate()
		#new_ship.ionized = true
	#elif pShieldShip:
		#new_ship = shield_ship_scene.instantiate()
		#new_ship.shield = true
	#else:
		#new_ship = ship_scene.instantiate()
		#
	#new_ship.ionized = pIonized
	#new_ship.sending_planet_id = sender
	#new_ship.destination_planet_id = destination
	#new_ship.direction = (destination.global_position - sender.global_position).normalized()
	#new_ship.alliance = sender.alliance
	#new_ship.speed =  new_ship.speed * sender.acceleration_ships
	#new_ship.stop_moving = false
	#return new_ship
	
func _physics_process(delta: float) -> void:
	if(!stop_moving):
		translate(delta * direction * speed)
	
func _ready() -> void:
	pass
#PLANETE OU SHIP DETECTE
func _on_area_entered(area: Area2D) -> void:
	if (area is Planet && area.planet_id == destination_planet_id && alliance == area.alliance):
		area.addShip(ionized)
		destroy("", area.alliance)
	elif(area is Planet && area.planet_id == destination_planet_id) : #Enemy planet 
		area.hit(damage, alliance)
		destroy("planet", area.alliance)
	elif(area is Ship && area.alliance != self.alliance): # vaisseau enemi
		if(!area is ShieldShip):
			destroy("ship", area.alliance)
	elif(area.has_method("reboot") && area.alliance != self.alliance && !area.is_empty()): #shield
		area.hit(shield_damage)
		destroy("shield", area.alliance)
		
func destroy(particules : String, hit_alliance : int ) -> void :
		get_parent().remove_ship()
		match particules :
			"planet":
				$ShipParticles.emitting = true
				$PlanetParticles.modulate = PlanetType.alliances_colors[hit_alliance]
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
	
		SyncManager.call_deferred("despawn",self)

func desactive_ship() -> void:
		$ShipSprite.hide()
		$CollisionShape2D.disabled
		stop_moving = true
		collision_layer = 0
		collision_mask = 0
		await get_tree().create_timer(lifetime_particles).timeout


func change_planet(new_planet : Planet):
	if(new_planet.planet_id == sending_planet_id):
		sending_planet_id = new_planet.planet_id
	else:
		destination_planet_id = new_planet.planet_id
