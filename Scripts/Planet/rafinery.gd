extends Planet

class_name Rafinery

@export var anim_curve : Curve
@export var spice_production_speed = 1.0
@export var production_total_duration = 1.0
var production_time = 0
var next_free_production : int
var free_production : int

func _process(delta: float) -> void:
	animate(delta)
	try_send_ship()
	update_text()
	
	if(number_of_ships >=1) :
		production_time += delta * spice_production_speed
		if(production_time > production_total_duration):
			$Smoke.restart()
			if(next_free_production <= free_production):
				number_of_ships -= 1
				next_free_production += 1
			else:
				next_free_production = 0
			production_time -= 1
			player.spices += 1
	

func animate(delta):
	var scale_vec = Vector2(self.base_scale + 0.1* log(float(number_of_ships + 1)), self.base_scale + 0.1* log(float(number_of_ships + 1)))
	if(number_of_ships > 0):
		scale = scale_vec * anim_curve.sample(production_time * (spice_production_speed / production_total_duration))
	if color_change_anim_time >= 0 :
		$PlanetSprite.material.set_shader_parameter('transition_time',color_change_anim_time)
		color_change_anim_time -= delta
	
