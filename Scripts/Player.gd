extends Camera2D

class_name Player

var alliance = PlanetType.Alliance.RED
# Called# Constantes pour les seuils
var active_touches_pos = {}

const MIN_ZOOM = 0.25
const MAX_ZOOM = 2

var previous_distance = 0
var delta_distance = 0

@export var planets : Node2D

var active_planet : Planet
var cursor

func _ready() -> void:
	assert(planets != null)
	set_player_in_nodes()
	cursor = $Cursor
	cursor.hide()
	
func _input(event):	
	if event is	InputEventScreenTouch :
			update_active_touches(event)
			update_initial_distance(event)	
			if(active_planet != null && event.is_released()): # TODO REFACTORISER
				select_planet()
			check_area(event)
			
	if event is	InputEventScreenDrag :
			update_active_touches(event)
			if(active_planet != null):
				preselect_planet()
			if(len(active_touches_pos) == 1) && active_planet == null:
				drag_screen(event)
			elif(len(active_touches_pos) == 2) && active_planet == null:
				zoom_screen(event)
				
	if event is InputEventKey :
		if event.as_text_key_label() == "A":
			emule_touch(event.pressed)

func update_initial_distance(event):
	if(len(active_touches_pos) == 2):
		previous_distance = active_touches_pos[0].distance_to(active_touches_pos[1])

func update_active_touches(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches_pos[event.index] = event.position
		else:
			active_touches_pos.erase(event.index)	
	elif event is InputEventScreenDrag:
		active_touches_pos[event.index]= event.position

func zoom_screen(event):
	delta_distance = previous_distance - active_touches_pos[0].distance_to(active_touches_pos[1])
	previous_distance = active_touches_pos[0].distance_to(active_touches_pos[1])
	var current_zoom = clamp(zoom.x + delta_distance * 0.01,MIN_ZOOM,MAX_ZOOM)
	zoom = Vector2(current_zoom, current_zoom)

func drag_screen(event):
	position -= event.screen_relative

func emule_touch(bol):
	var touch_1 = InputEventScreenTouch.new()
	touch_1.index = 1  # Premier doigt
	touch_1.position = Vector2(100, 10)  # Position de toucher du premier doigt
	touch_1.pressed = bol  # Doigt appuyé
	Input.parse_input_event(touch_1)

func set_player_in_nodes():
	for planet in planets.get_children():
		if(planet is Planet):
			planet.setPlayer(self)
	
func check_area(event):
	if(event.pressed):
		var space_state = get_world_2d().direct_space_state
		var physics_query = PhysicsPointQueryParameters2D.new()
		physics_query.collide_with_areas = true
		physics_query.collide_with_bodies = false
		physics_query.position = get_viewport().canvas_transform.affine_inverse() * event.position
		physics_query.collision_mask = 0b10
		var results = space_state.intersect_point(physics_query)

		for result in results:
			if(result.collider is Planet && result.collider.alliance == self.alliance):
				result.collider.enable_overlay(true)
				active_planet = result.collider
				cursor.show()
	else:
		if(active_planet != null):
			active_planet.enable_overlay(false)
			active_planet = null

func get_finger_pos() -> Vector2:
	if(len(active_touches_pos) == 1):
		return get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0]
	return Vector2.ZERO

func preselect_planet():
	active_planet.preselectClosestNeighbor(	get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0])
	cursor.global_position = active_planet.preselected_neighbor.position


func select_planet():
	active_planet.selectNeighbor()
	cursor.hide()
