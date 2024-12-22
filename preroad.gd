extends Node2D

class_name PreRoad
@export var radius : int
var origin_planet : Planet
var destination_planet : Planet

const my_scene: PackedScene = preload("res://Assets/Prefab/Road/preroad.tscn")

static func create_preroad(porigin_planet):
	var new_preroad = my_scene.instantiate() 
	new_preroad.origin_planet = porigin_planet
	porigin_planet.add_child(new_preroad)

func _ready():
	var normalized_size = float(radius) / $Sprite2D.texture.get_width()
	$Sprite2D.scale = Vector2(normalized_size,normalized_size )
	$Area2D.scale = Vector2(normalized_size,normalized_size )
	$Line2D.add_point(Vector2(0,0))
	$Line2D.add_point(Vector2(0,0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			find_active_planet_in_areas(event)
			set_destination_point(event)
		if event.is_released():
			if(destination_planet != null):
				origin_planet.make_road(destination_planet)
				queue_free()
	if event is InputEventScreenDrag:
		find_active_planet_in_areas(event)
		set_destination_point(event)

func get_event_position(event):
	var pos =  get_viewport().canvas_transform.affine_inverse() * event.position
	var range = origin_planet.position.distance_to(pos)
	if(range > radius):
		print("yooo man")
		pos = (pos * radius )/range
	return pos

func set_destination_point(event):
	if(destination_planet != null):
		$Line2D.set_point_position(destination_planet.global_position)
	else:
		$Line2D.set_point_position(1, get_event_position(event) - origin_planet.position)
		

func find_active_planet_in_areas(event):
	var space_state = get_world_2d().direct_space_state
	var physics_query = PhysicsPointQueryParameters2D.new()
	physics_query.collide_with_areas = true
	physics_query.collide_with_bodies = false
	physics_query.position = get_event_position(event)
	physics_query.collision_mask = 0b10
	var results = space_state.intersect_point(physics_query)
	for result in results:
		if(result.collider is Planet && !origin_planet.has_neighbor(result.collider)):
			print("yo")
			destination_planet = result.collider
			return
	destination_planet = null
