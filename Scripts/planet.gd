extends Area2D

class_name Planet

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
var selected_neighbor : Planet
var selected_road : Planet


var roads = {}

@export var alliance : PlanetType.Alliance

var player : Player

var current_overlay : OverlayPlanet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO Find Neighbors
	if(auto_find_neighbors):
		print("start detection")
		detect_neighbors()
		
	for neighbor in input_neighbors:
		roads[neighbor.name] = Road.create_road(self,neighbor)
		neighbor.setup_road(roads[neighbor.name], self)
		roads[neighbor.name].add_to_group("Roads")
		add_sibling.call_deferred(roads[neighbor.name]) #TODO pourquoi j'ai fais en call deferred
		if(!neighbors.has(neighbor.name)):
			neighbors[neighbor.name] = neighbor
	input_neighbors.clear()
	modulate = PlanetType.get_alliance_color(alliance)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	produce_ships(delta)
	animate()
	update_text()
	pass
	
func produce_ships(delta: float) -> void:
	if(len(neighbors) == 0): #Ne devrait pas etre necessaire
		return
	if(number_of_ships > send_ship_treshold && selected_neighbor != null && alliance != PlanetType.Alliance.NEUTRAL): # SI LE TRESHOLD EST ATTEINT ENVOI SHIP
		if(roads[selected_neighbor.name].send_ship(self)):
			number_of_ships -=1
			
	if(number_of_ships < max_ships) : # SI LE MAX EST PAS ATTEINT ON PRODUIT
		current_ship_production += delta * ship_speed_production
		if(current_ship_production >= 1):
			number_of_ships += 1
			current_ship_production -=1
	else : #SINON ON ENVOIE L'EXCES
		if(roads.size() >0 && selected_neighbor == null && alliance != PlanetType.Alliance.NEUTRAL && roads[neighbors.values().pick_random().name].send_ship(self) ):
			number_of_ships -=1
		else:
			current_ship_production = 0

func animate()->void :
	scale = Vector2(1 + 0.1* sqrt(float(number_of_ships + current_ship_production) / float(max_ships)), 1 + 0.1* sqrt(float(number_of_ships + current_ship_production) / float(max_ships)))

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
	number_of_ships -= 1
	if(number_of_ships < 0):
		self.alliance = aAlliance
		self.modulate = PlanetType.get_alliance_color(aAlliance)
		number_of_ships = 1

func enable_overlay(bol):
	if(bol):
		var overlay = OverlayPlanet.create_overlay(player)
		current_overlay = overlay
		add_child(overlay)
	else:
		current_overlay.queue_free()


func setPlayer(aPlayer):
	player = aPlayer

func preselectClosestNeighbor(touch_pos):
	if(len(neighbors) == 0):
		return
		
	var min_distance = neighbors.values()[0].global_position.distance_to(touch_pos)
	var closest_neighbor = neighbors.values()[0]
	
	for neighbor in neighbors.values():
		if(min_distance > neighbor.global_position.distance_to(touch_pos)):
			closest_neighbor = neighbor
			min_distance = neighbor.global_position.distance_to(touch_pos)
	preselected_neighbor = closest_neighbor
	
func selectNeighbor():
	if preselected_neighbor != null :
		selected_neighbor = preselected_neighbor

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
	physics_query.transform.origin = self.position
	
	var results = space_state.intersect_shape(physics_query)
	
	for result in results:
		if(result.collider is Planet):
			input_neighbors.append(result.collider)
	PhysicsServer2D.free_rid(circle)
