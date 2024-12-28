extends Node2D

class_name PreRoad
@export var radius : int
@export var clamp_radius : int
var origin_planet : Planet
var destination_planet : Planet

var planets : Array[Planet]
var active : bool
var destination_planet_candidates : Array[Planet]
const my_scene: PackedScene = preload("res://Assets/Prefab/Road/preroad.tscn")

var  game_manager

func _ready():
	game_manager  = get_node("/root/Level/GameManager")
	stop_preroad(false)

func use_on(porigin_planet : Planet, range : int):
	self.global_position = porigin_planet.position
	origin_planet = porigin_planet 
	radius = range
	var normalized_size = 2 * float(radius) / $Sprite2D.texture.get_width()
	$Sprite2D.scale = Vector2(normalized_size,normalized_size )
	$Line2D.add_point(Vector2(0,0))
	$Line2D.add_point(Vector2(0,0))

	if(	!check_for_candidates()):
		print("no candidates")
		stop_preroad(true)
		return #Pas possible de faire une route
	active = true
	$Sprite2D.show()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if !active:
		return
	if event is InputEventScreenTouch:
		if event.is_pressed():
			get_parent().drag_speed = 0
			if(self.global_position.distance_to(get_event_position(event)) < radius):
				check_candidates(event)
				set_destination_point(event)
				self.get_tree().get_root().set_input_as_handled()
			else:
				stop_preroad(true)
		if event.is_released():
			get_parent().drag_speed = 1
			if(destination_planet != null):
				origin_planet.make_road(destination_planet)
				origin_planet.update_color_of_road_to_neighbor(destination_planet.name)
				stop_preroad(false)
			self.get_tree().get_root().set_input_as_handled()
	if event is InputEventScreenDrag:
		check_candidates(event)
		set_destination_point(event)

func get_event_position(event):
	return get_viewport().canvas_transform.affine_inverse() * event.position
	

func set_destination_point(event):
	if(destination_planet != null):
		$Line2D.set_point_position(1, destination_planet.global_position - self.global_position)
	else:
		var dist = get_event_position(event).distance_to(origin_planet.global_position)
		if dist < radius :
			$Line2D.set_point_position(1, get_event_position(event) - origin_planet.position)
		else :
			$Line2D.set_point_position(1, (get_event_position(event) - origin_planet.position) * radius / dist)

		

func check_for_candidates() -> bool:
	var candidates = game_manager.get_planet_close_to(origin_planet, radius)
	var bol = false
	for planet in candidates:
		if( !origin_planet.has_neighbor(planet) && planet != origin_planet):	
			destination_planet_candidates.append(planet)
			print(str(planet.name))
			bol = true
	return bol
	
func check_candidates(event)->bool:
	var bol = false
	for candidat in destination_planet_candidates : 
		if get_event_position(event).distance_to(candidat.position)< clamp_radius :
			destination_planet = candidat
			return true
	destination_planet = null
	return false

func stop_preroad( payback : bool):
	if(payback):
		get_parent().refund_skill(origin_planet.skill.spice_cost)
	$Line2D.clear_points()
	destination_planet_candidates.clear()
	active = false
	$Sprite2D.hide()
