extends Resource
class_name PlanetData

enum Types{
	ACCELERATOR,
	GENERATOR,
	LABORATORY,
	RAFINERY,
	NORMAL,
	DEFENSIVE
}

@export var types_name = {
	Types.ACCELERATOR: "accelerator",
	Types.GENERATOR: "generator",
	Types.LABORATORY: "laboratory",
	Types.RAFINERY: "rafinery",
	Types.NORMAL: "normal",
	Types.DEFENSIVE : "defensive"
}

@export var types_cost = {
	Types.ACCELERATOR: 10,
	Types.GENERATOR: 15,
	Types.LABORATORY: 15,
	Types.RAFINERY: 20,
	Types.NORMAL: 0,
	Types.DEFENSIVE : 8
}

@export var production_speed = {
	Types.ACCELERATOR: 0.5,
	Types.GENERATOR: 1.75,
	Types.LABORATORY: 0,
	Types.RAFINERY: 0,
	Types.NORMAL: 1,
	Types.DEFENSIVE : 1
}
func get_cost(planet_type) -> int:
	if(planet_type in types_cost):
		return types_cost[planet_type]
	print(planet_type)
	return -1

func get_type_name(planet_type) -> String:
	if(planet_type in types_cost):
		return types_name[planet_type]
	print(planet_type)
	return ""
