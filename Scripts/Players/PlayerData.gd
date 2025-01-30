extends Node

class_name PlayerData

var player_name : String
var player_alliance : PlanetType.Alliance = PlanetType.Alliance.RED
var level : int = 0
var player_id : int = 0

func get_pd_as_dict():
	var dict = {}
	dict["name"] = player_name
	dict["level"] = level
	dict["id"] = player_id
	dict["alliance"] = player_alliance
	return dict
	
static func get_dict_as_pd(dict):
	var pd : PlayerData = PlayerData.new()
	pd.player_name = dict["name"]
	pd.player_alliance = dict["alliance"]
	pd.player_id = dict["id"]
	pd.level = dict["level"]
	return pd
