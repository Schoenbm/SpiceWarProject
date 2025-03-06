@tool
extends Area2D

class_name Planet

class arrivedShip:
	var strength : int
	var ionized : bool
signal change_alliance(previous_alliance, current_alliance)


@export var ship_speed_production = 1.0:
	set(value):
		if(produceShipTimer != null):
			produceShipTimer.wait_ticks = time_to_tick / value;
		ship_speed_production = value;
		
var current_ship_production = 0
@export var number_of_ships = 0
var number_of_ionized_ships = 0

var bonus_damage_ionized_ships = 0

@export var send_ship_threshold = 5
@export var search_neighbors = false
@export var radius_neighbors = 64
@export var input_neighbors: Array[Planet]
@export var neighbors = {}

var selected_neighbor = self
var selected_road : Planet

@export var shield : Shield

@export var send_ship_cd : float
@export var can_send_ship : bool
@export var acceleration_ships = 1
var roads = {}

@export var type : PlanetData.Types
@export var alliance : PlanetType.Alliance
@export var color_change_anim_duration = 0.15
var color_change_anim_time = 0

var player : Player
var planet_id = -1
var current_overlay : OverlayPlanet

var base_scale : float


#------------------------------------------------------------------------

var skill : Skill
@export var base_skill : Skill
@export var upgraded_skill : Skill
var is_skill_upgraded = false
var can_use_skill : bool
var send_random : bool
var send_all : bool

var magnet = false
@export var magnet_force = 2.0

var network_production_bonus = 1
var network_flowrate_bonus = 1

signal self_updated(planet: Planet)

@export var starter_player = 0
var gm : GameManager

var time_to_tick = 60

var produceShipTimer : NetworkTimer
var lastAttackingShipAlliance : PlanetType.Alliance
var damageBetweenTicks : int
var regenBetweenTicks : int
var alliedArrivingShips : Array
var enemyArrivingShips : Array

func _ready():
	produceShipTimer = $ProduceShipTimer
	gm = get_parent().get_parent()
	skill = base_skill
	$ShipTimer.wait_ticks = send_ship_cd * time_to_tick
	produceShipTimer.wait_ticks = time_to_tick / ship_speed_production
	can_send_ship = true
	base_scale = self.scale.x
	selected_neighbor = self
	send_random = false
	can_use_skill = true
	
	
# Called when the node enters the scene tree for the first time.
func setup(aPlayer = null, new_planet_id = -1) -> void:

	$PermanentCursorPivot.hide() #cache le curseur avant d'attaquer
	$PlanetSprite.material.set_shader_parameter('transition_time',0)
	$PlanetSprite.material.set_shader_parameter('transition_duration',color_change_anim_duration)
	player = aPlayer
	
	if(new_planet_id != -1):
		planet_id = new_planet_id
		
	if(search_neighbors):
		build_roads()
	$PlanetSprite.material.set_shader_parameter('previous_color',PlanetType.get_alliance_color(alliance))
	change_color_alliance(alliance, true)

		


func set_planet_id(value):
	planet_id = value

func build_roads():
	detect_neighbors()
	var n_neigh = 0
	for neighbor in input_neighbors:
		if(!roads.has(neighbor.planet_id)):
			if(neighbor.planet_id == -1):
				print(-1)
			make_road(neighbor)
			n_neigh += 1


func has_neighbor(neighbor : Planet) -> bool:
	return roads.has(neighbor.planet_id)
	
func make_road(neighbor : Planet):
	roads[neighbor.planet_id] = Road.create_road(self,neighbor)
	neighbor.setup_road(roads[neighbor.planet_id], self)
	roads[neighbor.planet_id].add_to_group("Roads")
	get_parent().get_parent().get_node("AllRoads").add_child(roads[neighbor.planet_id])
	if Engine.is_editor_hint():
		roads[neighbor.planet_id].set_owner(get_tree().edited_scene_root)
	add_neighbor(neighbor)

func change_color_alliance(pAlliance, first_time):
	$PlanetSprite.material.set_shader_parameter('color',PlanetType.get_alliance_color(pAlliance))
	color_change_anim_time = color_change_anim_duration
	if(!first_time):
		await get_tree().create_timer(color_change_anim_duration).timeout
	$PlanetSprite.material.set_shader_parameter('transition_time',0)
	for road in roads.values():
		road.update_color(!first_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(Engine.is_editor_hint()):
		return;
	update_text()
	animate(delta)


func _network_process(input : Dictionary) -> void:
	process_arrived_ships()
	if(alliance != PlanetType.Alliance.NEUTRAL):
		try_send_ship()
	if(number_of_ships < 0):
		set_alliance(lastAttackingShipAlliance, false)
		number_of_ships = 0

func process_arrived_ships():
	for ship in alliedArrivingShips:
		number_of_ships += ship.strength
		number_of_ionized_ships += int(ship.ionized)
	alliedArrivingShips.clear()
	for ship in enemyArrivingShips:
		hit(ship.strength)
	enemyArrivingShips.clear()

func boot():
	if(alliance != PlanetType.Alliance.NEUTRAL):
		$ProduceShipTimer.start()
		$ShipTimer.start()
	set_physics_process(true)
	
func try_send_ship() -> void : 
	if(len(neighbors) > 0 && can_send_ship): # SI LE threshold EST ATTEINT ENVOI SHIP
		can_send_ship = false
		if(send_random && number_of_ships > send_ship_threshold):
			send_ship(roads.values().pick_random())
		elif(send_all):
			for road in roads.values():
				send_ship(road)
		elif (selected_neighbor != self && number_of_ships > send_ship_threshold):
			send_ship(roads[selected_neighbor.planet_id])


func send_ship(road : Road):
	if(number_of_ships >= 1):
		road.send_ship(self, number_of_ionized_ships > 0, bonus_damage_ionized_ships)
		reduce_ships_number(1)


func animate(delta)->void :
	
	self.scale = Vector2(self.base_scale + 0.01* log(float(number_of_ships + 1)), self.base_scale + 0.01* log(float(number_of_ships + 1)))
	if color_change_anim_time >= 0 :
		$PlanetSprite.material.set_shader_parameter('transition_time',color_change_anim_time)
		color_change_anim_time -= delta


func update_text() -> void:
	if(number_of_ionized_ships > 0):
		$IonizedLabel.text = "(" + str(number_of_ionized_ships) + ")"	
	else:
		$IonizedLabel.text = ""	
	$TextEdit.text = str(number_of_ships)
	
func clean_neighbors():
	neighbors.clear()
	input_neighbors.clear()
	roads.clear()
		
func setup_road(new_road : Road, neighbor : Planet ) -> void:
	if(!roads.has(neighbor.planet_id)):
		roads[neighbor.planet_id] = new_road
	add_neighbor(neighbor)
	
func addShip(aAlliance, strength, ionized : bool):
	var ship = arrivedShip.new()
	ship.strength = strength
	ship.ionized = ionized
	if(alliance == aAlliance):
		alliedArrivingShips.append(ship)
	else:
		enemyArrivingShips.append(ship)
		lastAttackingShipAlliance = aAlliance;

func ionize_ship() -> bool:
	if(number_of_ships > number_of_ionized_ships):
		if($IonizedTimer.is_stopped()):
			$IonizedTimer.start()
		number_of_ionized_ships += 1
		return true
	return false
	
func hit(damage : int) -> void:
	if(shield != null && shield.activated):
		shield.hit(damage)
		return
	reduce_ships_number(damage)



func set_alliance(aAlliance, first_time):
		self.alliance = aAlliance
		if(!first_time):
			change_alliance.emit(self, aAlliance)
			$PlanetSprite.material.set_shader_parameter('previous_color',PlanetType.get_alliance_color(alliance)) #TODO on previent que cetait l'alliance davant au shader, pe faire ça ailleurs			
			particles_effect()
		
		if(aAlliance == PlanetType.Alliance.NEUTRAL):
			$ProduceShipTimer.stop()
		else:
			$ProduceShipTimer.start()
			
		if(shield != null):
			shield.alliance = aAlliance
		change_color_alliance(alliance, first_time)
		for road in roads.values():
			road.start_color_transition()
		
func particles_effect():
	$CircleParticles.modulate = PlanetType.get_alliance_color(alliance)
	$CircleParticles.emitting = true
	$BarParticles.emitting = true
	
func enable_overlay(bol):
	if(bol):
		var overlay = OverlayPlanet.create_overlay(player)
		current_overlay = overlay
		add_child(overlay)
	else:
		current_overlay.queue_free()


#Selectionne le voisin attaqué et montre qu'il est attaqué, previent les deux routes du changement
func confirm_attack_on_planet(planet : Planet):
	if planet != self:
		if(selected_neighbor != self):
			roads.get(selected_neighbor.planet_id).manage_planet_attack(self,false)
		if(roads.has(planet.planet_id)):
			roads.get(planet.planet_id).manage_planet_attack(self,true)
		else:
			print(planet_id)
		$PermanentCursorPivot.look_at(planet.position)
		$PermanentCursorPivot.show()
		start_attack(planet)
	else:
		$PermanentCursorPivot.hide()
		start_attack(planet)


func start_attack(attacked_planet : Planet):
	selected_neighbor = attacked_planet
	enable_ship_timer(attacked_planet != self)
	
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


func transform_planet(new_planet : Planet) -> void :
	new_planet.alliance = alliance
	new_planet.number_of_ships = number_of_ships
	new_planet.neighbors = neighbors
	new_planet.roads = roads
	new_planet.current_ship_production = current_ship_production
	new_planet.global_position = self.global_position
	new_planet.search_neighbors = false
	new_planet.name = self.name 
	new_planet.planet_id = planet_id
	
	new_planet.setup(player)

	for neighbor in neighbors.values() :
		neighbor.add_neighbor(new_planet)
		neighbor.change_selected_neighbor(new_planet)
	for road in new_planet.roads.values() :
		road.change_planet(self, new_planet)
	

	
	name = "GLORIOUS_EVOLUTION" 
	add_sibling(new_planet)
	player.update_active_planet_upgrade(new_planet)
	new_planet.particles_effect()
	new_planet.boot()
	if(selected_neighbor != self):
		new_planet.confirm_attack_on_planet(selected_neighbor)
	
	self_updated.emit(new_planet)
	self.queue_free()
	
	
func add_neighbor(new_planet : Planet):
	if(neighbors.has(new_planet.planet_id)):
		neighbors.erase(new_planet.planet_id)
	neighbors[new_planet.planet_id] = new_planet

func change_selected_neighbor(new_planet : Planet):
	if(selected_neighbor.planet_id == new_planet.planet_id):
		selected_neighbor = new_planet
		
func cancel_attack():
	confirm_attack_on_planet(self)
	
func skill_in_use(bol):
	can_use_skill = !bol


func change_cooldown_ships(cd : float = -1):
	if(cd == -1):
		cd = send_ship_cd
	$ShipTimer.wait_ticks = cd / network_flowrate_bonus * time_to_tick
	acceleration_ships = network_flowrate_bonus

func enable_ship_timer(bol):
	if(bol):
		$ShipTimer.start()
	else:
		$ShipTimer.stop()

func set_durability_ionized_ships(time : float):
	$IonizedTimer.wait_ticks = time * time_to_tick
	
func reduce_ships_number(amount : int):
	number_of_ships -= amount
	if(number_of_ionized_ships > 0):
		number_of_ionized_ships = max( 0,number_of_ionized_ships - amount)

func update_color_of_road_to_neighbor(neighbor_planet_id : String):
	if(roads.has(neighbor_planet_id)):
		roads[neighbor_planet_id].update_color(true)

func set_shield(scale, max_capacity, regen):
	$Shield.shield_max_capacity = max_capacity
	$Shield.shield_regen_delay = regen
	$Shield.scale = Vector2(scale,scale)

func get_shield_capacity() -> int:
	return $Shield.shield_capacity
	
func upgrade_skill(bol):
	if(bol):
		skill = upgraded_skill
	else:
		skill = base_skill

func regen_shield(regen : int):
	$Shield.regen_shield(1)
	
func is_shield_full() -> bool :
	if(shield != null && shield.is_full()):
		return true
	return false
	
func _save_state() -> Dictionary:
	var state = {
		"selected_neighbor_id" : selected_neighbor.planet_id,
		"number_of_ships" : number_of_ships,
		"number_of_ionized_ships" : number_of_ionized_ships,
		"alliance" : alliance,
		"shield_capacity" : shield.shield_capacity,
	}
	return state

func _load_state(state):
	selected_neighbor = gm.planets[state["selected_neighbor_id"]]
	number_of_ships = state["number_of_ships"]
	number_of_ionized_ships = state["number_of_ionized_ships"]
	alliance = state["alliance"] 
	shield.shield_capacity = state["shield_capacity"]

	


func _on_ship_timer_timeout() -> void:
	can_send_ship = true
	if(selected_neighbor.magnet && !send_all && !send_random && $ShipTimer.wait_ticks == send_ship_cd * time_to_tick):
		$ShipTimer.wait_ticks = (send_ship_cd *  magnet_force) * time_to_tick
		print("magnet " + str(send_ship_cd * magnet_force))
	elif ($ShipTimer.wait_ticks != send_ship_cd * time_to_tick) :
		$ShipTimer.wait_ticks = send_ship_cd * time_to_tick


func _on_ionized_timer_timeout() -> void:
	number_of_ionized_ships -= 1
	if(number_of_ionized_ships <= 0):
		number_of_ionized_ships = 0
		$IonizedTimer.stop()


func _on_produce_ship_timeout() -> void:
	number_of_ships += 1;
