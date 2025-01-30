extends Area2D

class_name Shield

@export var shield_capacity = 0
@export var shield_regen_delay = 1
@export var shield_max_capacity = 15
@export var shield_reboot_time = 5 #si égal a -1 ne peut pas reboot

@export var dormant_shield : bool

var activated;
var time_elapsed_before_reboot = 0
var time_elapsed_between_charges = 0

var fade_state = 0
var faded: bool

var alliance : PlanetType.Alliance

func _ready():
	$ShieldSprite.material.set_shader_parameter('charged',false)
	$ShieldSprite.material.set_shader_parameter('fade_state', 0)
	alliance = get_parent().alliance

	activated = !dormant_shield
	faded = !activated
	call_deferred("enable_shield", activated)
	
	if(faded):
		fade_state = 0.5
	else:
		fade_state = 0
	
	$ShieldSprite.material.set_shader_parameter('fade_state', fade_state)
	time_elapsed_before_reboot = 0.5
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!dormant_shield && activated && shield_capacity < shield_max_capacity ):
		time_elapsed_between_charges += delta
		if time_elapsed_between_charges >= shield_regen_delay  :
			shield_capacity += 1
			time_elapsed_between_charges = 0
			if(shield_capacity == shield_max_capacity):
				$ShieldSprite.material.set_shader_parameter('charged',true)
	elif(!activated && !dormant_shield):
		reboot(delta);
	
	if(fade_state <0.5 && faded):
		fade_state += delta
		$ShieldSprite.material.set_shader_parameter('fade_state', fade_state)
	elif(fade_state > 0 && !faded):
		fade_state = max(0,fade_state - delta)
		$ShieldSprite.material.set_shader_parameter('fade_state', fade_state)
		if(fade_state == 0):
			call_deferred("enable_shield", true)

#Reactive automatiquement le shield et s'occupe des animations
func reboot(delta : float):
	time_elapsed_before_reboot += delta
	
	if(time_elapsed_before_reboot > shield_reboot_time):
		activated = true
		time_elapsed_before_reboot = 0
		time_elapsed_between_charges = 0
		call_deferred("enable_shield", true);
		faded = false



func hit(damage):
	deplete_energy(damage)
	$ShieldSprite.material.set_shader_parameter('hit', true)
	$Timer.start()

func deplete_energy(amount):
		shield_capacity = ( max(0, shield_capacity - amount))
		$ShieldSprite.material.set_shader_parameter('charged',false)
		if(shield_capacity == 0):
			time_elapsed_before_reboot = 0
			time_elapsed_between_charges = 0
			call_deferred("enable_shield", false)
			activated = false
			faded = true
	
func is_active() -> bool:
	return shield_capacity < shield_max_capacity
	
func _on_timer_timeout():
		$ShieldSprite.material.set_shader_parameter('hit', false)

func regen_shield(amount : int):
	shield_capacity = min(shield_capacity + amount, shield_max_capacity)
	activated = true
	faded = false
	if(shield_capacity == shield_max_capacity): 
		$ShieldSprite.material.set_shader_parameter('charged',true)

func enable_shield(bol : bool):
	$CollisionShape2D.disabled = !bol

func get_alliance():
	return alliance

func is_full() -> bool:
	return shield_capacity >= shield_max_capacity

func is_empty() -> bool :
	return shield_capacity == 0
