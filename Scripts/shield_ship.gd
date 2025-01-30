extends Ship

class_name ShieldShip



func _on_area_entered(area: Area2D) -> void:
	if (area is Planet && area.planet_id == destination_planet_id && alliance == area.alliance):
		area.regen_shield(1)
		destroy("", alliance)
	elif(area is Planet && area.planet_id == destination_planet_id) : #Enemy planet 
		destroy("planet", area.alliance)
	elif(area is Ship && area.alliance != self.alliance): # vaisseau enemi
		destroy("ship", area.alliance)
	elif(area is Shield && area.activated && area.alliance != self.alliance): #shield
		destroy("shield", area.alliance)
