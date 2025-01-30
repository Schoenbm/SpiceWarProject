extends Player

class_name LocalPlayer


var active_touches_pos = {}

const MIN_ZOOM = 0.25
const MAX_ZOOM = 2

var drag_speed = 1
var visible_width
var visible_height
var window_size
 
@export var cancel_attack_radius = 60

var previous_distance = 0
var delta_distance = 0

var spices = 0

var planet_data  = load("res://Assets/Resources/PlanetData.tres")

@export var bound : Vector2
var active_planet : Planet
var preselected_planet : Planet
var cursor

var choose_attack_mode : bool 
var upgrade_menu_oppened : bool
var spawn_camera : Vector2

var context_menu : ContextMenu

@export var spell_cooldown : Array[float]
var spell_cooldown_tier = 0
var can_use_spell : bool

var camera : Camera2D
#------------ TECHNOLOGY -----------------

func preparePlayer() -> void:
	can_use_spell = true
	upgrade_menu_oppened = false
	choose_attack_mode = false
	cursor = $Cursor
	camera = $Camera2D
	$SpellCD.wait_time = spell_cooldown[0]
	cursor.hide()
	context_menu = get_parent().get_node("UI/CanvasLayer")
	window_size = get_viewport().size
	gm.get_node("PlayerUI").set_player(self)
	
	visible_width = window_size.x / camera.zoom.x
	visible_height = window_size.y / camera.zoom.y

func clamp_pos():
	position.x = clamp(position.x, 0, bound.x)
	position.y = clamp(position.y, 0, bound.y)
	

func _unhandled_input(event):
	
	if event is	InputEventScreenTouch :
			update_active_touches(event)
			update_initial_distance(event)
			
			if(event.is_pressed() && upgrade_menu_oppened):
				upgrade_menu_oppened = false
				active_planet = null
				context_menu.player_close_context_menu()
			
			var planet = find_planet(event)
			if(event.double_tap && planet != null):
				planet.cancel_attack()
			elif(active_planet != null && event.is_released()):
				if(choose_attack_mode):
					confirm_attack()
					activate_attack_mode(false)
				else:
					context_menu.player_open_context_menu(active_planet)
					upgrade_menu_oppened = true
			elif(event.is_pressed()):
				active_planet = planet

				
	if event is	InputEventScreenDrag :
			update_active_touches(event)
			
			if(active_planet != null && get_event_positition(event).distance_to(active_planet.position) > cancel_attack_radius && !choose_attack_mode):
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
	var current_zoom = clamp(camera.zoom.x + delta_distance * 0.01,MIN_ZOOM,MAX_ZOOM)
	camera.zoom = Vector2(current_zoom, current_zoom)
	visible_width = window_size.x / camera.zoom.x
	visible_height = window_size.y / camera.zoom.y
	clamp_pos()

func drag_screen(event):
	position -= event.screen_relative *  drag_speed
	clamp_pos()

func emule_touch(bol):
	var touch_1 = InputEventScreenTouch.new()
	touch_1.index = 1  # Premier doigt
	touch_1.position = Vector2(100, 10)  # Position de toucher du premier doigt
	touch_1.pressed = bol  # Doigt appuyé
	Input.parse_input_event(touch_1)


func find_planet(event) -> Planet:
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
				return result.collider
	return null

	
func get_finger_pos() -> Vector2:
	if(len(active_touches_pos) == 1):
		return get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0]
	return Vector2.ZERO

func preselect_planet():
	preselectClosestNeighbor(	get_viewport().canvas_transform.affine_inverse() * active_touches_pos[0])
	cursor.global_position = preselected_planet.global_position


func confirm_attack():
	print("attak")
	input_attack_planet(active_planet.planet_id, preselected_planet.planet_id)
	cursor.hide()


func activate_attack_mode(bol : bool) :
	if(bol):
		cursor.show()
		var overlay = OverlayPlanet.create_overlay(self)
		active_planet.current_overlay = overlay
		active_planet.add_child(overlay)
	else :
		cursor.hide()
		active_planet.current_overlay.queue_free()

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

func enable_preroad(range : int):
	$Preroad.use_on(active_planet, range)

func refund_skill(cost : int):
	spices += cost
	enable_spell(true)

func preselectClosestNeighbor(touch_pos):
	if(len(active_planet.neighbors) == 0):
		return
		
	var min_distance = active_planet.neighbors.values()[0].global_position.distance_to(touch_pos)
	var closest_neighbor = active_planet.neighbors.values()[0]
	preselected_planet = active_planet
	for neighbor in active_planet.neighbors.values():
		if(min_distance > neighbor.global_position.distance_to(touch_pos)):
			closest_neighbor = neighbor
			min_distance = neighbor.global_position.distance_to(touch_pos)
	if(active_planet.global_position.distance_to(touch_pos) > cancel_attack_radius):
		preselected_planet = closest_neighbor

func upgrade_spell_cooldown():
	spell_cooldown_tier += 1
	$SpellCD.wait_time = spell_cooldown[spell_cooldown_tier]
