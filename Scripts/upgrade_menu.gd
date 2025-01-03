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

@export var player : Player

var parent_control : Control

@export var gm : GameManager

var end_anim : bool
func _ready():
	if (gm == null):
		gm = get_node("/root/Level/GameManager")
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
	gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR),PlanetData.Types.ACCELERATOR, active_planet)


func _on_shield_button_pressed() -> void:
	gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE),PlanetData.Types.DEFENSIVE, active_planet)


func _on_generator_button_pressed() -> void:
	gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.GENERATOR), PlanetData.Types.GENERATOR, active_planet)


func _on_rafinery_button_pressed() -> void:
	gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.RAFINERY), PlanetData.Types.RAFINERY, active_planet)


func _on_laboratory_button_pressed() -> void:
	gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.LABORATORY), PlanetData.Types.LABORATORY,active_planet)


func _on_spell_button_pressed() -> void:
	player.try_spell()


func player_open_context_menu(planet : Planet) -> void:
	active_planet = planet
	$ThresholdSlider.value = active_planet.send_ship_threshold
	$ThresholdSlider/Treshold.text = str(active_planet.send_ship_threshold)
	if(active_planet.skill != null):
		$SpellButton/Cost.text = str(active_planet.skill.spice_cost)

	update_menu_for_active_planet()
	popup(true)



func update_menu_for_active_planet():
	$AccelerationButton.disabled = false
	$ShieldButton.disabled = false
	$GeneratorButton.disabled = false
	$RafineryButton.disabled = false
	$LaboratoryButton.disabled = false
	$SpellButton.disabled = !active_planet.can_use_skill || !player.can_use_spell
	
	match active_planet.type :
		PlanetData.Types.GENERATOR : $GeneratorButton.disabled = true
		PlanetData.Types.DEFENSIVE : $ShieldButton.disabled = true
		PlanetData.Types.ACCELERATOR : $AccelerationButton.disabled = true
		PlanetData.Types.RAFINERY : 
			$RafineryButton.disabled = true
			$SpellButton.disabled = true
			print("here")
		PlanetData.Types.LABORATORY : $LaboratoryButton.disabled = true
	

		

func player_close_context_menu() -> void:
	popup(false)
	
func has_point(point) -> bool:
	return parent_control.get_global_rect().has_point(point)

func update_planet(updated_planet):
	active_planet = updated_planet
	update_menu_for_active_planet()
	
func enable_spell_button(bol : bool):
	if(active_planet != null):
		bol = bol && active_planet.can_use_skill
	$SpellButton.disabled = !bol 
