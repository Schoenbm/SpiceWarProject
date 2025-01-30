extends Node

@export var action_lag : int = 3
var current_tick : int = 0
@export var mini_tick_treshold : int = 200
var mini_tick : int = 0
var u_tick : int = 0

var delay

var is_server = false

@export var sync_delay : int = 5

var client_latency = 0
var client_delta_latency = 0
var client_latency_array = []
var client_latency_index = 0

var callables_array = []
signal ping_updated

var gm : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func get_delayed_tick():
	return current_tick + action_lag
	
func add_callable(new_callable : CallableOnTick):
	if(new_callable.tick <= current_tick):
		print("Desync")
		new_callable.call_function()
		pass #ROLLBACK omg scary
	callables_array.append(new_callable)

func sync_peers_clocks():
	mini_tick = 0
	u_tick = 0
	current_tick = 0
	restart_internal_clock.rpc()

@rpc("authority", "reliable")
func restart_internal_clock():
	mini_tick = client_latency
	u_tick = 0
	current_tick = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_process(delta: float) -> void:
	mini_tick += int(delta * 1000) + client_delta_latency
	client_latency = 0
	u_tick += int((delta *1000 - mini_tick) * 1000)
	
	if(u_tick >= 1000):
		mini_tick += 1
		
	if(mini_tick >= mini_tick_treshold):
		mini_tick -= mini_tick_treshold
		current_tick += 1
		clock_tick()

func clock_tick():
	for function in callables_array:
		if(function.is_good_tick(current_tick)):
			function.call()
			callables_array.erase(function)

@rpc("any_peer","reliable")
func ping( time_send):
	pong.rpc_id(multiplayer.get_remote_sender_id(),time_send)

@rpc("authority","reliable")
func pong(time_send):
	client_latency_array.append((Time.get_ticks_msec() - time_send) / 2)
	
	
func _on_connection():
	var latency_timer = Timer.new()
	latency_timer.wait_time = 0.5
	latency_timer.autostart = true
	latency_timer.timeout.connect("determine_latency")
	self.add_child(latency_timer)
	
func determine_latency():
	var latency = 0
	if(client_latency_array.size() == 9):
		client_latency_array.sort()
		var mid_value = client_latency_array[4]
		for i in range(client_latency_array.size()-1, -1, -1):
			if(client_latency_array[i] > 2 * mid_value && client_latency_array[i] > 30):
				client_latency_array.remove(i)
			else:
				latency += client_latency_array[i]
		client_delta_latency = latency - client_latency
		client_latency = latency / client_latency_array.size()
		ping_updated.emit()
	ping.rpc_id(1,Time.get_ticks_msec())

func queue_start_attack(atk_planet : Planet, def_planet : Planet):
	var planets_id = 1000 * atk_planet.planet_id + def_planet.planet_id
	queue_peer_start_attack.rpc(planets_id, current_tick + action_lag)

@rpc("any_peer","reliable","call_local")
func queue_peer_start_attack(planets_id : int, func_tick : int):
	var atk_planet = gm.get_planet(planets_id / 1000)
	var def_planet = gm.get_planet( planets_id - int(planets_id / 1000) * 1000)
	
	var start_attack_call = CallableOnTick.new()
	start_attack_call.function.create(atk_planet,"start_attack")
	start_attack_call.function.bind(def_planet)
	start_attack_call.tick = func_tick
	add_callable(start_attack_call)
	
	
