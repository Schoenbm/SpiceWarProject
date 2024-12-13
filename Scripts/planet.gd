extends Area2D

class_name Planet

signal change_alliance(previous_alliance, current_alliance)

@export var ship_speed_production = 1.0 # nombre de cell par sec
var current_ship_production = 0
@export var number_of_ships = 0

@export var send_ship_threshold = 5
@export var auto_find_neighbors = false
@export var radius_neighbors = 64
@export var input_neighbors: Array[Planet]
var neighbors = {}

var preselected_neighbor : Planet
var selected_neighbor = self
var selected_road : Planet

@export var shield : Shield

@export var acceleration_ships = 1
var roads = {}

@export var type : PlanetData.Types
@export var alliance : PlanetType.Alliance
@export var color_change_anim_duration = 0.15
var color_change_anim_time = 0

var player : Player

var current_overlay : OverlayPlanet

var base_scale : float

const planet_prefab : PackedScene = preload("res://Assets/Prefab/Planets/planet.tscn")
const defensive_planet_prefab : PackedScene = preload("res://Assets/Prefab/Planets/defensive_planet.tscn")
const generator_prefab : PackedScene = preload("res://Assets/Prefab/Planets/generator.tscn")
const accelerator_prefab : PackedScene = preload("res://Assets/Prefab/Planets/acceleration_planet.tscn")
#const laboratory_prefab : PackedScene = preload("res://Assets/Prefab/Planets/laboratory.tscn")
#const rafinnery_prefab : PackedScene = preload("res://Assets/Prefab/Planets/rafinery.tscn")



func _ready() -> void:
	base_scale = scale.x
	selected_neighbor = self
	preselected_neighbor = self
	
# Called when the node enters the scene tree for the first time.
func setup(aPlayer) -> void:
	$PermanentCursorPivot.hide() #cache le curseur avant d'attaquer
	$PlanetSprite.material.set_shader_parameter('transition_time',0)
	$PlanetSprite.material.set_shader_parameter('transition_duration',color_change_anim_duration)
	player = aPlayer
	if(auto_find_neighbors):
		detect_neighbors()
	
	for neighbor in input_neighbors:
		if(!roads.has(neighbor.name)):
			roads[neighbor.name] = Road.create_road(self,neighbor)
			neighbor.setup_road(roads[neighbor.name], self)
			roads[neighbor.name].add_to_group("Roads")
			add_sibling.call_deferred(roads[neighbor.name]) #TODO pourquoi j'ai fais en call deferred
			neighbors[neighbor.name] = neighbor
	input_neighbors.clear()
	$PlanetSprite.material.set_shader_parameter('previous_color',PlanetType.get_alliance_color(alliance))
	change_color_alliance(alliance, true)




func change_color_alliance(pAlliance, first_time):
	$PlanetSprite.material.set_shader_parameter('color',PlanetType.get_alliance_color(pAlliance))
	color_change_anim_time = color_change_anim_duration
	if(!first_time):
		await get_tree().create_timer(color_change_anim_duration).timeout
	$PlanetSprite.material.set_shader_parameter('transition_time',0)
	for road in roads.values():
		road.update_color(!first_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	produce_ships(delta)
	animate(delta)
	send_ship()
	update_text()
	pass
	

func send_ship() -> void : 
	if(len(neighbors) > 0 && number_of_ships > send_ship_threshold && selected_neighbor != self && alliance != PlanetType.Alliance.NEUTRAL): # SI LE threshold EST ATTEINT ENVOI SHIP
		if(roads[selected_neighbor.name].send_ship(self)):
			number_of_ships -=1


func produce_ships(delta: float) -> void:
	current_ship_production += delta * ship_speed_production
	if(current_ship_production >= 1):
		number_of_ships += 1
		current_ship_production -=1


func animate(delta)->void :
	scale = Vector2(self.base_scale + 0.1* log(float(number_of_ships + 1)), self.base_scale + 0.1* log(float(number_of_ships + 1)))
	if color_change_anim_time >= 0 :
		$PlanetSprite.material.set_shader_parameter('transition_time',color_change_anim_time)
		color_change_anim_time -= delta


func update_text() -> void:
	$TextEdit.text = str(number_of_ships)
	
func setup_road(new_road : Road, neighbor : Planet ) -> void:
	if(!roads.has(neighbor.name)):
		roads[neighbor.name] = new_road
	if(!neighbors.has(neighbor.name)):
		neighbors[neighbor.name] = neighbor
	
func addShip():
	number_of_ships +=1
	
func hit(aAlliance : PlanetType.Alliance) -> void:
	if(shield != null && shield.activated):
		shield.hit(1)
		return
		
	number_of_ships -= 1
	if(number_of_ships < 0):
		change_alliance.emit(alliance, aAlliance)
		$CircleParticles.emitting = true
		$CircleParticles.modulate = PlanetType.get_alliance_color(aAlliance)
		$BarParticles.emitting = true
		$PlanetSprite.material.set_shader_parameter('previous_color',PlanetType.get_alliance_color(alliance)) #TODO on previent que cetait l'alliance davant au shader, pe faire ça ailleurs
		self.alliance = aAlliance
		if(shield != null):
			shield.alliance = aAlliance
		change_color_alliance(alliance, false)
		for road in roads.values():
			road.start_color_transition()
		number_of_ships = 1

func enable_overlay(bol):
	if(bol):
		var overlay = OverlayPlanet.create_overlay(player)
		current_overlay = overlay
		add_child(overlay)
	else:
		current_overlay.queue_free()

func preselectClosestNeighbor(touch_pos):
	preselected_neighbor = self
	if(len(neighbors) == 0):
		return
		
	var min_distance = neighbors.values()[0].global_position.distance_to(touch_pos)
	var closest_neighbor = neighbors.values()[0]
	
	for neighbor in neighbors.values():
		if(min_distance > neighbor.global_position.distance_to(touch_pos)):
			closest_neighbor = neighbor
			min_distance = neighbor.global_position.distance_to(touch_pos)
	if(global_position.distance_to(touch_pos) > 40):
		preselected_neighbor = closest_neighbor

#Selectionne le voisin attaqué et montre qu'il est attaqué, previent les deux routes du changement
func confirm_attack_on_preselected_neighbor():
	if preselected_neighbor != self:
		#if(selected_neighbor != self):
			#roads.get(selected_neighbor.name).manage_planet_attack(self, false) # wtf why ?
		selected_neighbor = preselected_neighbor
		roads.get(selected_neighbor.name).manage_planet_attack(self,true)
		$PermanentCursorPivot.look_at(selected_neighbor.position)
		$PermanentCursorPivot.show()
	else:
		$PermanentCursorPivot.hide()
		selected_neighbor = self

#Detecte tout les voisins dans un cercle de rayon neighbor_radius et les place dans input_neighbors
func detect_neighbors():
	var space_state = get_world_2d().direct_space_state
	
	var circle = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(circle, radius_neighbors)
	var physics_query = PhysicsShapeQueryParameters2D.new()
	physics_query.shape_rid = circle
	physics_query.collision_mask = 0b10
	physics_query.collide_with_areas = true
	physics_query.collide_with_bodies = false
	physics_query.transform.origin = self.position # TODO AMELIORER CA CAR ORIGIN VA CHANGER SI ON DEPLACE PLANETS
	
	var results = space_state.intersect_shape(physics_query)
	
	for result in results:
		if(result.collider is Planet && result.collider != self):
			input_neighbors.append(result.collider)
	PhysicsServer2D.free_rid(circle)

func production_upgrade():
	ship_speed_production *= 1.15


func upgrade_planet(planet_name : PlanetData.Types) -> void :
	var new_planet : Planet
	match planet_name :
		PlanetData.Types.GENERATOR : new_planet = generator_prefab.instantiate()
		PlanetData.Types.DEFENSIVE : new_planet = defensive_planet_prefab.instantiate()
		PlanetData.Types.ACCELERATOR : new_planet = accelerator_prefab.instantiate()
		"_" : 
			print("names dont match") 
			return
	new_planet.alliance = alliance
	new_planet.number_of_ships = number_of_ships
	new_planet.neighbors = neighbors
	new_planet.roads = roads
	new_planet.current_ship_production = current_ship_production
	new_planet.global_position = self.global_position
	new_planet.auto_find_neighbors = false
	new_planet.name = self.name 
	
	new_planet.setup(player)
	for neighbor in neighbors.values() :
		neighbor.add_neighbor(new_planet)
		neighbor.change_selected_neighbor(new_planet)
	for road in new_planet.roads.values() :
		road.change_planet(self, new_planet)
	
	name = "GLORIOUS_EVOLUTION" 
	add_sibling(new_planet)
	player.active_planet = new_planet
	self.queue_free()
	
	
func try_upgrade(cost : int, planet_type : PlanetData.Types) -> bool:
	if(number_of_ships >= cost):
		number_of_ships -= cost
		upgrade_planet(planet_type)
		return true
	return false
	
func add_neighbor(new_planet : Planet):
	if(neighbors.has(new_planet.name)):
		neighbors.erase(new_planet.name)
	neighbors[new_planet.name] = new_planet

func change_selected_neighbor(new_planet : Planet):
	if(selected_neighbor.name == new_planet.name):
		print("same name")
		selected_neighbor = new_planet
		preselected_neighbor = new_planet
	print(new_planet.name + " " + selected_neighbor.name)
