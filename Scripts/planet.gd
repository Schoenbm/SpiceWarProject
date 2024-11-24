extends Area2D

class_name Planet

@export var ship_speed_production = 1.0 # nombre de cell par sec
var current_ship_production = 0
var number_of_ships = 0

@export var max_ships = 10

@export var auto_find_neighbors = false
@export var neighbors: Array[Planet]
var road_set = false

var roads : Array[Road]

enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO Find Neighbors
	for neighbor in neighbors:
		if(!neighbor.road_set) :
			roads.append(Road.create_road(self,neighbor))
			neighbor.add_road(roads.back())
			roads.back().add_to_group("Roads")
			add_sibling.call_deferred(roads.back())
			print("yooooooo " + str(roads.size()))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	produce_ships(delta)
	animate()
	update_text()
	pass
	
func produce_ships(delta: float) -> void:
	if(number_of_ships < max_ships) :
		current_ship_production += delta * ship_speed_production
		if(current_ship_production >= 1):
			number_of_ships += 1
			current_ship_production -=1
	else :
		if(roads.size() >0):
			roads.pick_random().send_ship(self)
		current_ship_production = 0

func animate()->void :
	$AnimatedSprite2D.play()
	#scale = Vector2(1 + 0.2 * sqrt(float(number_of_ships + current_ship_production) / float(max_ships)), 1 + 0.2 * sqrt(float(number_of_ships + current_ship_production) / float(max_ships)))

func update_text() -> void:
	$TextEdit.text = str(number_of_ships) + " / " + str(max_ships)
	
func add_road(new_road : Road) -> void:
	roads.append(new_road)
	
func addShip() -> bool:
	if(number_of_ships < max_ships):
		number_of_ships +=1
		return true
	return false