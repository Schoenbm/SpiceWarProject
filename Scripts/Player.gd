extends Camera2D

class_name Player

var alliance = PlanetType.Alliance.RED
# Called# Constantes pour les seuils
var active_touches_pos = {}

const MIN_ZOOM = 0.25
const MAX_ZOOM = 2

var visible_width
var visible_height
var window_size

var previous_distance = 0
var delta_distance = 0

var planet_data  = load("res://Assets/Resources/PlanetData.tres")

@export var long_touch : float
var touch_time : float

@export var bound : Vector2
var active_planet : Planet
var cursor

var short_touch : bool
var choose_attack_mode : bool 
var upgrade_menu_oppened : bool

@export var context_menu : ContextMenu

func _ready() -> void:
	touch_time = long_touch
	upgrade_menu_oppened = false
	choose_attack_mode = false
	short_touch = false
	cursor = $Cursor
	cursor.hide()
	window_size = get_viewport().size
	visible_width = window_size.x / zoom.x
	visible_height = window_size.y / zoom.y

func clamp_pos():
	position.x = clamp(position.x, visible_width / 2, bound.x - visible_width / 2)
	position.y = clamp(position.y, visible_height / 2, bound.y - visible_height / 2)
	
func _process(delta: float) -> void:
	if(touch_time < long_touch && active_planet != null):
		touch_time += delta
		if(touch_time >= long_touch):
			activate_attack_mode(true)


func _unhandled_input(event):
	if(upgrade_menu_oppened):
		if(!event.is_pressed()):
			return
		upgrade_menu_oppened = false
		active_planet = null
		context_menu.player_close_context_menu()
		
	if event is	InputEventScreenTouch :
			update_active_touches(event)
			update_initial_distance(event)
			update_timer_long_touch(event)
			if(active_planet != null && choose_attack_mode && event.is_released()): # TODO REFACTORISER
				confirm_attack()
				activate_attack_mode(false)
				short_touch = false
			if(active_planet != null && short_touch && event.is_released()):
				context_menu.player_open_context_menu(active_planet)
				upgrade_menu_oppened = true
				short_touch = false
			if(active_planet != null && event.is_released()):
				active_planet == null
			find_active_planet_in_areas(event)
			
	if event is	InputEventScreenDrag :
			update_active_touches(event)
			if(active_planet != null && choose_attack_mode):
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
	visible_width = window_size.x / zoom.x
	visible_height = window_size.y / zoom.y
	clamp_pos()

func drag_screen(event):
	position -= event.screen_relative
	clamp_pos()

func emule_touch(bol):
	var touch_1 = InputEventScreenTouch.new()
	touch_1.index = 1  # Premier doigt
	touch_1.position = Vector2(100, 10)  # Position de toucher du premier doigt
	touch_1.pressed = bol  # Doigt appuyé
	Input.parse_input_event(touch_1)

func find_active_planet_in_areas(event):
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
				active_planet = result.collider
	else:
		if(active_planet != null && choose_attack_mode):
			active_planet = null

func get_finger_pos() -> Vector2:
	if(len(active_touches_pos) == 1):
		return get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0]
	return Vector2.ZERO

func preselect_planet():
	active_planet.preselectClosestNeighbor(	get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0])
	cursor.global_position = active_planet.preselected_neighbor.position


func confirm_attack():
	active_planet.confirm_attack_on_preselected_neighbor()
	cursor.hide()
	

func _on_ui_try_upgrade(planet_type: PlanetData.Types) -> void:
	if(active_planet != null && active_planet.try_upgrade(planet_data.get_cost(planet_type), planet_type)):
		print("upgraded")
	else :
		print(active_planet != null)

func activate_attack_mode(bol : bool) :
	if(bol):
		cursor.show()
	else :
		cursor.hide()
	active_planet.enable_overlay(bol)
	choose_attack_mode = bol

func update_timer_long_touch(event : InputEventScreenTouch):
	if(len(active_touches_pos) == 1 && event.pressed ):
		touch_time = 0
	elif(len(active_touches_pos) == 0 && touch_time < long_touch && event.is_released()):
		short_touch = true
		touch_time = long_touch
	else:
		touch_time = long_touch
		
