extends OptionButton

func _ready() -> void:
	for alliance in PlanetType.Alliance.values():
		if(alliance != PlanetType.Alliance.NEUTRAL):
			var str = PlanetType.get_alliance_name(alliance)
			add_item(PlanetType.get_alliance_name(alliance), alliance as int)


func _on_item_selected(index: int) -> void:
	LocalPlayerData.player_alliance = index
	print(PlanetType.Alliance.find_key(index) + str(LocalPlayerData.player_alliance) + " " + str(index))
	MultiplayerManager.local_alliance_change()
