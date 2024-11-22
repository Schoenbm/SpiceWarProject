extends Area2D


@export var cells_speed_production = 0.0 # nombre de cell par sec
var current_cell_production = 0
var number_of_cells = 0	

@export var max_cells = 0

enum {UNIT_NEUTRAL, UNIT_ENEMY, UNIT_ALLY}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	produce_cells(delta)
	animate()
	update_text()
	pass
	
func produce_cells(delta: float) -> void:
	if(number_of_cells < max_cells) :
		current_cell_production += delta
		if(current_cell_production >= 1):
			number_of_cells += 1
			current_cell_production -=1
	else :
		current_cell_production = 0

func animate()->void :
	$AnimatedSprite2D.play()
	scale = Vector2(1 + 0.2 * sqrt(float(number_of_cells) / float(max_cells)), 1 + 0.2 * sqrt(float(number_of_cells) / float(max_cells)))

func update_text():
	$TextEdit.text = str(number_of_cells) + " / " + str(max_cells)
