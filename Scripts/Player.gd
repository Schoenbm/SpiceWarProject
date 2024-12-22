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

var spices = 0

var planet_data  = load("res://Assets/Resources/PlanetData.tres")

@export var bound : Vector2
var active_planet : Planet
var cursor

var choose_attack_mode : bool 
var upgrade_menu_oppened : bool

@export var context_menu : ContextMenu

@export var spell_cooldown : float
var can_use_spell : bool

func _ready() -> void:
	can_use_spell = true
	upgrade_menu_oppened = false
	choose_attack_mode = false
	cursor = $Cursor
	$SpellCD.wait_time = spell_cooldown
	cursor.hide()
	window_size = get_viewport().size
	visible_width = window_size.x / zoom.x
	visible_height = window_size.y / zoom.y

func clamp_pos():
	position.x = clamp(position.x, visible_width / 2, bound.x - visible_width / 2)
	position.y = clamp(position.y, visible_height / 2, bound.y - visible_height / 2)
	

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
			if(event.double_tap):
				if(active_planet !=null):
					find_active_planet_in_areas(event)
					active_planet.selected_neighbor = active_planet
			elif(active_planet != null && event.is_released()):
				if(choose_attack_mode):
					confirm_attack()
					activate_attack_mode(false)
				else:
					context_menu.player_open_context_menu(active_planet)
					upgrade_menu_oppened = true
			elif(event.is_pressed()):
				active_planet = null
				find_active_planet_in_areas(event)
				
	if event is	InputEventScreenDrag :
			update_active_touches(event)
			
			if(active_planet != null && get_event_positition(event).distance_to(active_planet.position) > active_planet.radius && !choose_attack_mode):
				activate_attack_mode(true)
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
		physics_query.position = get_event_positition(event)
		physics_query.collision_mask = 0b10
		var results = space_state.intersect_point(physics_query)

		for result in results:
			if(result.collider is Planet && result.collider.alliance == self.alliance):
				print("find planet")
				active_planet = result.collider
	else:
		print("lool")
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
	


func activate_attack_mode(bol : bool) :
	if(bol):
		cursor.show()
	else :
		cursor.hide()
	active_planet.enable_overlay(bol)
	choose_attack_mode = bol

func get_event_positition(event):
	return  get_viewport().canvas_transform.affine_inverse() * event.position

func update_active_planet_upgrade(upgraded_planet):
	active_planet = upgraded_planet
	context_menu.update_planet(upgraded_planet)

func try_spell():
	if(can_use_spell && active_planet != null && active_planet.can_use_skill && active_planet.skill.buy_skill(spices)):
		spices -= active_planet.skill.spice_cost
		active_planet.skill.use_skill(active_planet)
		enable_spell(false)
		$SpellCD.start()
	else:
		print("can't spell : " + str(can_use_spell) + str(active_planet != null) +  str(active_planet.can_use_skill) + str(active_planet.skill.buy_skill(spices)))
	
func _on_timer_timeout() -> void:
	print("cd over")
	enable_spell(true)
	
func enable_spell(bol : bool):
	context_menu.enable_spell_button(bol)
	can_use_spell = bol
