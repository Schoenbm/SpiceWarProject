extends Area2D

class_name Planet

signal change_alliance(previous_alliance, current_alliance)

@export var ship_speed_production = 1.0 # nombre de cell par sec
var current_ship_production = 0
@export var number_of_ships = 0

@export var max_ships = 10
@export var send_ship_treshold = 5
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

@export var alliance : PlanetType.Alliance
@export var color_change_anim_duration = 0.15
var color_change_anim_time = 0

var player : Player

var current_overlay : OverlayPlanet

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
	change_color_alliance(alliance)
	selected_neighbor = self



func change_color_alliance(pAlliance):
		$PlanetSprite.material.set_shader_parameter('previous_color',PlanetType.get_alliance_color(alliance))
		$PlanetSprite.material.set_shader_parameter('color',PlanetType.get_alliance_color(pAlliance))
		color_change_anim_time = color_change_anim_duration
		await get_tree().create_timer(color_change_anim_duration).timeout
		for road in roads.values():
			road.update_color()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	produce_ships(delta)
	animate(delta)
	update_text()
	pass
	
func produce_ships(delta: float) -> void:
	if(len(neighbors) == 0): #Ne devrait pas etre necessaire
		return
	if(number_of_ships > send_ship_treshold && selected_neighbor != self && alliance != PlanetType.Alliance.NEUTRAL): # SI LE TRESHOLD EST ATTEINT ENVOI SHIP
		if(roads[selected_neighbor.name].send_ship(self)):
			number_of_ships -=1
			
	if(number_of_ships < max_ships) : # SI LE MAX EST PAS ATTEINT ON PRODUIT
		current_ship_production += delta * ship_speed_production
		if(current_ship_production >= 1):
			number_of_ships += 1
			current_ship_production -=1
	else : #SINON ON ENVOIE L'EXCES
		if( roads.size() >0 && selected_neighbor == self && alliance != PlanetType.Alliance.NEUTRAL && roads[neighbors.values().pick_random().name].send_ship(self) ):
			number_of_ships -=1
		else:
			current_ship_production = 0


func animate(delta)->void :
	scale = Vector2(1 + 0.1* sqrt(float(number_of_ships + current_ship_production) / float(max_ships)), 1 + 0.1* sqrt(float(number_of_ships + current_ship_production) / float(max_ships)))
	if(color_change_anim_time > 0):
		$PlanetSprite.material.set_shader_parameter('transition_time',color_change_anim_duration - color_change_anim_duration)
		color_change_anim_time -= delta

func update_text() -> void:
	$TextEdit.text = str(number_of_ships) + " / " + str(max_ships)
	
func setup_road(new_road : Road, neighbor : Planet ) -> void:
	if(!roads.has(neighbor.name)):
		roads[neighbor.name] = new_road
	if(!neighbors.has(neighbor.name)):
		neighbors[neighbor.name] = neighbor
	
func addShip() -> bool:
	if(number_of_ships < max_ships):
		number_of_ships +=1
		return true
	return false
	
func hit(aAlliance : PlanetType.Alliance) -> void:
	if(shield != null && shield.activated):
		shield.hit(1)
		return
		
	number_of_ships -= 1
	if(number_of_ships < 0):
		change_alliance.emit(alliance, aAlliance)
		self.alliance = aAlliance
		if(shield != null):
			shield.alliance = aAlliance
		change_color_alliance(alliance)
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
func selectNeighbor():
	if preselected_neighbor != self:
		if(selected_neighbor != self):
			roads.get(selected_neighbor.name).manage_planet_attack(self, false)
		selected_neighbor = preselected_neighbor
		roads.get(selected_neighbor.name).manage_planet_attack(self,true)
		$PermanentCursorPivot.look_at(selected_neighbor.position)
		$PermanentCursorPivot.show()
	else:
		$PermanentCursorPivot.hide()

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
