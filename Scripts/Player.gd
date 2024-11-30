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

func _ready() -> void:
	assert(planets != null)
	set_player_in_nodes()
	
func _input(event):	
	if event is	InputEventScreenTouch :
			update_active_touches(event)
			update_initial_distance(event)	
			check_area(event)
	if event is	InputEventScreenDrag && active_planet != null:
			if(len(active_touches_pos) == 1):
				drag_screen(event)
			elif(len(active_touches_pos) == 2):
				zoom_screen(event)
				
	if event is InputEventKey :
		if event.as_text_key_label() == "A":
			emule_touch(event.pressed)

func update_initial_distance(event):
	if(len(active_touches_pos) == 2):
		previous_distance = active_touches_pos[0].distance_to(active_touches_pos[1])

func update_active_touches(event):
	if event.pressed:
		print("press")
		active_touches_pos[event.index] = event.position
	else:
		active_touches_pos.erase(event.index)	
		

func zoom_screen(event):
	active_touches_pos[event.index] = event.position
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
		var results = space_state.intersect_point(event.position)
		for result in results:
			if(result is Planet):
				result.enableOverlay(true)
				active_planet = result
	else:
		active_planet.enableOverlay(false)
		active_planet = null
