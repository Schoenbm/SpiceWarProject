extends Node2D


class_name Road
var current_ships_number = 0

@export var planet1 : Planet
@export var planet2 : Planet

@export var flow_rate : float
var flow_cd_planet1 = 0
var flow_cd_planet2 = 0



@export var attack_animation_speed : float
@export var wobble_animation_speed : float
@export var wobble_animation_frequency : float

@export var transition_color_max_time = 0.0
var transition_color_time = 0
var transition_locked = false #Pour eviter des calculs inutiles 

var planet1_attacking = false;
var planet2_attacking = false;
const my_scene: PackedScene = preload("res://Assets/Prefab/road.tscn")


static func create_road(P1: Planet, P2: Planet) -> Road :
	var new_road : Road = my_scene.instantiate()
	new_road.planet1 = P1
	new_road.planet2 = P2

	new_road.name = P1.name + "to" + P2.name
	return new_road

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepareRoadSprite()

func _process(delta : float) -> void:
	if(flow_cd_planet1>0):
		flow_cd_planet1-= delta
	if(flow_cd_planet2>0):
		flow_cd_planet2-= delta
	transition_color(delta)

	
	
func transition_color(delta : float) -> void:
	if(transition_color_time < transition_color_max_time):
		$RoadTexture.material.set_shader_parameter('transition_time', transition_color_time)
		transition_color_time += delta
	elif(!transition_locked):
		transition_locked = true;
		$RoadTexture.material.set_shader_parameter('color_begin', PlanetType.get_alliance_color(planet1.alliance))
		$RoadTexture.material.set_shader_parameter('color_end', PlanetType.get_alliance_color(planet2.alliance))


#renvoie true si le ship est bien enboyé
func send_ship(sender : Planet) -> bool:
	if(check_flow_rate_by_planet(sender)): # Road full et débit ok? 
		current_ships_number+=1
		var destination : Planet
		if(sender == planet1):
			destination = planet2
		else:
			destination = planet1
		var new_ship = Ship.create_ship(destination,sender)
		new_ship.name = "ship" + PlanetType.get_alliance_name(sender.alliance) + str(current_ships_number) #TODO EURK
		add_child(new_ship)
		put_flow_on_cd(sender)
		return true
	return false



func put_flow_on_cd(planet : Planet):
	if(planet == planet1):
		flow_cd_planet1 = flow_rate / planet.acceleration_ships # Plus les vaisseaux sont accelerees, moins ça prends du temps de tirer
	else:
		flow_cd_planet2 = flow_rate / planet.acceleration_ships

func check_flow_rate_by_planet(planet : Planet) -> bool:
	if(planet == planet1):
		return(flow_cd_planet1 <= 0)
	return(flow_cd_planet2 <= 0)

func get_current_ships(alliance:) -> int:
		return current_ships_number

func remove_ship():
	current_ships_number -= 1

func prepareRoadSprite():
	var dist = planet1.global_position.distance_to(planet2.global_position)
	var size_texture = $RoadTexture.texture.get_width()
	$RoadTexture.scale.x = dist / size_texture
	$RoadTexture.offset.x = size_texture / 2
	$RoadTexture.position = planet1.global_position
	$RoadTexture.look_at(planet2.global_position)
	transition_color_time = transition_color_max_time
	$RoadTexture.material.set_shader_parameter('transition_time', transition_color_max_time)
	$RoadTexture.material.set_shader_parameter('transition_end_time', transition_color_max_time)


func update_color(particules_effect : bool):
	$RoadTexture.material.set_shader_parameter('temp_begin_color', PlanetType.get_alliance_color(planet1.alliance))
	$RoadTexture.material.set_shader_parameter('temp_end_color', PlanetType.get_alliance_color(planet2.alliance))
	if(particules_effect && planet1.alliance == planet2.alliance):
		$RoadTexture/GPUParticles2D.modulate = PlanetType.get_alliance_color(planet1.alliance)
		$RoadTexture/GPUParticles2D.emitting = true
		
	
func start_color_transition():
	transition_color_time = 0
	transition_locked = false
	
func manage_planet_attack(planet : Planet, isAttacking : bool):
	planet1_attacking = isAttacking && planet1 == planet
	planet2_attacking = isAttacking && planet2 == planet
	if planet1_attacking:
		$RoadTexture.material.set_shader_parameter('speed', -1 * attack_animation_speed )
	if planet2_attacking:
		$RoadTexture.material.set_shader_parameter('speed', attack_animation_speed )
	
	if(planet1_attacking == planet2_attacking):
		$RoadTexture.material.set_shader_parameter('wobble', true )	
	else:
		$RoadTexture.material.set_shader_parameter('wobble', false )	

func change_planet(previous_planet : Planet, new_planet : Planet):
	
	if(previous_planet == planet1):
		planet1 = new_planet
	else:
		planet2 = new_planet
	
	for child in get_children():
		if(child is Ship):
			child.destination_planet = new_planet
