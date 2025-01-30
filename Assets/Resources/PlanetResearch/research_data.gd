extends Resource
class_name ResearchData

enum TechnologyBranch{
	ACCELERATOR,
	GENERATOR,
	RAFINERY,
	SHIELD,
	NETWORK
}

var name = {
	TechnologyBranch.ACCELERATOR: "accelerator",
	TechnologyBranch.GENERATOR: "generator",
	TechnologyBranch.RAFINERY: "rafinery",
	TechnologyBranch.SHIELD: "shield",
	TechnologyBranch.NETWORK : "network"
}
