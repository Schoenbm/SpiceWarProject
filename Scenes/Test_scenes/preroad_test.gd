extends Node2D

@export var planet : Planet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("start")

func start():
	$GameManager/Player/Preroad.use_on(planet)
