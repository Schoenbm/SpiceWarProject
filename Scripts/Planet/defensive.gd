extends Planet


class_name Defensive


func _network_process(input : Dictionary) -> void:
	if(alliance != PlanetType.Alliance.NEUTRAL):
		try_send_ship()
	var mini_shield = false
	if(mini_shield):
		send_mini_shield()
	update_text()


func send_mini_shield():
	if(shield.shield_capacity == shield.shield_max_capacity && $MiniShieldTimer.is_stopped()):
		$MiniShieldTimer.start()
		print("lets go" + str(shield.shield_capacity))
	elif(!$MiniShieldTimer.is_stopped() && shield.shield_capacity < shield.shield_max_capacity ):
		$MiniShieldTimer.stop()


func _on_mini_shield_timer_timeout() -> void:
	for neighbor in neighbors.values() :
		if(!neighbor.is_shield_full() && neighbor.alliance == alliance):
			roads[neighbor.name].send_ship(self, false, 0, true)
