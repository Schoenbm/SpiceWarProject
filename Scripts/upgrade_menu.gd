extends CanvasLayer
class_name ContextMenu

var PLANET_DATA  = load("res://Assets/Resources/PlanetData.tres")
@export var popup_anim_duration : float
var popup_anim_time : float

var base_offset : float
var hide_offset : float
var diff_offset = 300
var show : bool

var active_planet : Planet

signal try_upgrade(planet_type : PlanetData.Types) 

var parent_control : Control

func _ready():
	parent_control = get_parent()
	base_offset = self.offset.y
	hide_offset = self.offset.y + diff_offset
	offset.y = hide_offset
	$AccelerationButton/CostText.text = str(PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR))
	$ShieldButton/CostText.text = str(PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE))
	$GeneratorButton/CostText.text = str(PLANET_DATA.get_cost(PlanetData.Types.GENERATOR))
	$RafineryButton/CostText.text = str(PLANET_DATA.get_cost(PlanetData.Types.RAFINERY))
	$LaboratoryButton/CostText.text = str(PLANET_DATA.get_cost(PlanetData.Types.LABORATORY))
	
func popup(a_show : bool):
	popup_anim_time = popup_anim_duration
	show = a_show
	
func _process(delta):
	if(popup_anim_time > 0 && show):
		popup_anim_time -= delta
		self.offset.y = base_offset + diff_offset * max(0,(popup_anim_time / popup_anim_duration))
	
	if(popup_anim_time > 0 && !show):
		popup_anim_time -= delta
		self.offset.y = hide_offset - diff_offset * max(0,(popup_anim_time / popup_anim_duration))
	
	if(show && active_planet != null):
		active_planet.send_ship_threshold = $ThresholdSlider.value
		$ThresholdSlider/Treshold.text = str(active_planet.send_ship_threshold)



func _on_acceleration_button_pressed() -> void:
	try_upgrade.emit(PlanetData.Types.ACCELERATOR)


func _on_shield_button_pressed() -> void:
	try_upgrade.emit(PlanetData.Types.DEFENSIVE)


func _on_generator_button_pressed() -> void:
	try_upgrade.emit(PlanetData.Types.GENERATOR)


func _on_rafinery_button_pressed() -> void:
	try_upgrade.emit(PlanetData.Types.RAFINERY)


func _on_laboratory_button_pressed() -> void:
	try_upgrade.emit(PlanetData.Types.LABORATORY)


func player_open_context_menu(planet : Planet) -> void:
	active_planet = planet
	$ThresholdSlider.value = active_planet.send_ship_threshold
	$ThresholdSlider/Treshold.text = str(active_planet.send_ship_threshold)
	popup(true)


func player_close_context_menu() -> void:
	active_planet = null
	popup(false)
	
func has_point(point) -> bool:
	return parent_control.get_global_rect().has_point(point)
