extends Node2D

@export var planet1 : Planet
@export var planet2 : Planet
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var road := Road.create_road(planet1, planet2)
	add_child(road)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
