extends Area2D

class_name Shield

@export var shield_capacity = 0
@export var shield_regen_delay = 1
@export var shield_max_capacity = 15
@export var shield_reboot_time = 5

var activated = true;
var time_elapsed_before_reboot = 0
var time_elapsed_between_charges = 0

var alliance : PlanetType.Alliance

func _ready():
	$ShieldSprite.material.set_shader_parameter('charged',false)
	$ShieldSprite.material.set_shader_parameter('fade_state', 0)
	alliance = get_parent().alliance
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(activated && shield_capacity < shield_max_capacity ):
		time_elapsed_between_charges += delta
		if time_elapsed_between_charges >= shield_regen_delay  :
			shield_capacity += 1
			time_elapsed_between_charges = 0
			if(shield_capacity == shield_max_capacity):
				$ShieldSprite.material.set_shader_parameter('charged',true)
	elif(!activated):
		reboot(delta);

#Reactive automatiquement le shield et s'occupe des animations
func reboot(delta : float):
	time_elapsed_before_reboot += delta
	if(time_elapsed_before_reboot < 0.5): # le 0.5 est du au fait que c'est la valeur max de fade_state
		$ShieldSprite.material.set_shader_parameter('fade_state', time_elapsed_before_reboot)  
		
	if(time_elapsed_before_reboot > shield_reboot_time):
		activated = true
		time_elapsed_before_reboot = 0
		time_elapsed_between_charges = 0
	elif(time_elapsed_before_reboot > shield_max_capacity - 0.5): # Ici aussi
		$ShieldSprite.material.set_shader_parameter('fade_state', shield_max_capacity - time_elapsed_before_reboot)


func hit(damage):
	deplete_energy(damage)
	$ShieldSprite.material.set_shader_parameter('hit', true)
	$Timer.start()

func deplete_energy(amount):
		shield_capacity = ( max(0, shield_capacity - amount))
		$ShieldSprite.material.set_shader_parameter('charged',false)
		if(shield_capacity == 0):
			time_elapsed_before_reboot = 0;
			time_elapsed_between_charges = 0;
			activated = false;
	
func is_active() -> bool:
	return shield_capacity < shield_max_capacity
	
func _on_timer_timeout():
		$ShieldSprite.material.set_shader_parameter('hit', false)
