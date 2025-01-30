extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SyncManager.ping_updated.connect(_on_ping_update)
	get_parent().hide()


func _on_ping_update():
	#text = "Ping : " + SyncManager.client_latency
	get_parent().show()
	
