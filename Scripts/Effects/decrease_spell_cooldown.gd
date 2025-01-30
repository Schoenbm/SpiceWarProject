extends "res://Assets/Resources/technology_effect/Upgrade.gd"


func apply_effect_on_player(player : LocalPlayer):
	player.upgrade_spell_cooldown()
	
func get_effect_description(tier, player : Player = null) -> String:
	return effect_description + str(player.spell_cooldown[player.spell_cooldown_tier]) + " -> " +  str(player.spell_cooldown[player.spell_cooldown_tier])
