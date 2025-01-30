@tool
extends EditorScript

func _run() -> void:
	var file = FileAccess.open_compressed("user://detailed_logs/sample_log.log", FileAccess.READ)
	while not file.eof_reached():
		var data = file.get_var()
		var oct = file.get_8()
		print(data)  # Affiche chaque valeur décodée
		print(oct)
	file.close()
