class_name PlanetType

enum Alliance{
	RED,
	BLUE,
	GREEN,
	YELLOW,
	NEUTRAL
}

static var alliances_colors = {
	Alliance.RED: Color(1, 0, 0),    # Rouge
	Alliance.BLUE: Color(0, 0, 1),   # Bleu
	Alliance.GREEN: Color(0, 1, 0),  # Vert
	Alliance.YELLOW: Color(1, 1, 0),  # Jaune
	Alliance.NEUTRAL: Color(0.3, 0.3, 0.3)  # Neutral
}

static var alliances_string = {
	Alliance.RED: "red",    # Rouge
	Alliance.BLUE: "blue",   # Bleu
	Alliance.GREEN: "green",  # Vert
	Alliance.YELLOW: "yellow",  # Jaune
	Alliance.NEUTRAL: "neutral"  # Neutral
}
static func get_alliance_color(alliance) -> Color:
	if alliance in alliances_colors:
		return alliances_colors[alliance]
	return Color(1, 1, 1) 

static func get_alliance_name(alliance) -> String:
	if alliance in alliances_colors:
		return alliances_string[alliance]
	return "Unknown"
