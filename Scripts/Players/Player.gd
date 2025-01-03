extends Node2D

class_name Player

var technology_tiers = {}
var increase_ionize_lifespan_factor = 1
var spell_cooldown_tier = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for branch in ResearchData.TechnologyBranch:
		technology_tiers[branch] = 0
	preparePlayer()
	pass # Replace with function body.

func preparePlayer():
	pass
