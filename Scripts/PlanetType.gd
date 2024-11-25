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
static func get_alliance_color(alliance) -> Color:
	if alliance in alliances_colors:
		return alliances_colors[alliance]
	return Color(1, 1, 1) 
