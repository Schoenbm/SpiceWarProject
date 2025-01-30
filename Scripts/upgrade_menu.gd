extends CanvasLayer
class_name ContextMenu

var player 

var PLANET_DATA  = load("res://Assets/Resources/PlanetData.tres")
@export var popup_anim_duration : float
var popup_anim_time : float

var base_offset : float
var hide_offset : float
var diff_offset = 250

var show : bool

var active_planet : Planet

var parent_control : Control

@export var gm : GameManager

@export var ResearchMenu : Control

@export var AcceleratorButtonText : Label
@export var ShieldButtonText : Label
@export var GeneratorButtonText : Label
@export var RafineryButtonText : Label
@export var LaboratoryButtonText : Label

@export var AcceleratorButton : Button
@export var ShieldButton : Button
@export var GeneratorButton : Button
@export var RafineryButton : Button
@export var LaboratoryButton : Button

@export var SpellButton : Button
@export var SpellButtonText : Label

@export var ExpendButton : Button

@export var ThresholdSlider : HSlider
@export var ThresholdText : Label

@export var PlanetText :Label

@export var accel_icon : Texture2D
@export var shield_icon: Texture2D
@export var generator_icon : Texture2D
@export var rafinery_icon : Texture2D
@export var laboratory_icon : Texture2D
@export var sell_icon : Texture2D

@export var spell_accel_icon : Texture2D
@export var spell_shield_icon: Texture2D
@export var spell_generator_icon : Texture2D
@export var spell_rafinery_icon : Texture2D
@export var spell_laboratory_icon : Texture2D
@export var spell_normal_icon : Texture2D

var show_research = true

var end_anim : bool
func _ready():
	if (gm == null):
		gm = get_parent().get_parent()
	gm.local_player_setup.connect(_on_local_player_setup)
	base_offset = self.offset.y
	hide_offset = self.offset.y + diff_offset
	offset.y = hide_offset



func popup(a_show : bool):
	popup_anim_time = popup_anim_duration
	show = a_show
	if(show_research == true && active_planet.type == PlanetData.Types.LABORATORY && a_show):
		show_research_menu(true)
	else:
		show_research_menu(false)
	
func _process(delta):
	if(popup_anim_time > 0 && show):
		popup_anim_time -= delta
		self.offset.y = base_offset + diff_offset * max(0,(popup_anim_time / popup_anim_duration))
	
	if(popup_anim_time > 0 && !show):
		popup_anim_time -= delta
		self.offset.y = hide_offset - diff_offset * max(0,(popup_anim_time / popup_anim_duration))


func _on_acceleration_button_pressed() -> void:
	player.input_upgrade_planet(active_planet.planet_id, PlanetData.Types.ACCELERATOR)
	if(active_planet.type == PlanetData.Types.ACCELERATOR):
		gm.try_upgrade(-PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR)/2,PlanetData.Types.NORMAL, active_planet)
	else:
		gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR),PlanetData.Types.ACCELERATOR, active_planet)
	update_menu_for_active_planet()



func _on_shield_button_pressed() -> void:
	player.input_upgrade_planet(active_planet.planet_id, PlanetData.Types.ACCELERATOR)
	if(active_planet.type == PlanetData.Types.DEFENSIVE):
		gm.try_upgrade(-PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE)/2,PlanetData.Types.NORMAL, active_planet)
	else:
		gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE),PlanetData.Types.DEFENSIVE, active_planet)
	update_menu_for_active_planet()


func _on_generator_button_pressed() -> void:
	player.input_upgrade_planet(active_planet.planet_id, PlanetData.Types.GENERATOR)
	if(active_planet.type == PlanetData.Types.GENERATOR):
		gm.try_upgrade(-PLANET_DATA.get_cost(PlanetData.Types.GENERATOR)/2,PlanetData.Types.NORMAL, active_planet)
	else :
		gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.GENERATOR), PlanetData.Types.GENERATOR, active_planet)
	update_menu_for_active_planet()


func _on_rafinery_button_pressed() -> void:
	player.input_upgrade_planet(active_planet.planet_id, PlanetData.Types.RAFINERY)
	if(active_planet.type == PlanetData.Types.RAFINERY):
		gm.try_upgrade(-PLANET_DATA.get_cost(PlanetData.Types.RAFINERY)/2,PlanetData.Types.NORMAL, active_planet)
	else :
		gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.RAFINERY), PlanetData.Types.RAFINERY, active_planet)
	update_menu_for_active_planet()


func _on_laboratory_button_pressed() -> void:
	player.input_upgrade_planet(active_planet.planet_id, PlanetData.Types.LABORATORY)
	if(active_planet.type == PlanetData.Types.LABORATORY):
		gm.try_upgrade(-PLANET_DATA.get_cost(PlanetData.Types.LABORATORY)/2,PlanetData.Types.NORMAL, active_planet)
	else :
		gm.try_upgrade(PLANET_DATA.get_cost(PlanetData.Types.LABORATORY), PlanetData.Types.LABORATORY,active_planet)
	update_menu_for_active_planet()


func _on_spell_button_pressed() -> void:
	player.try_spell()


func player_open_context_menu(planet : Planet) -> void:
	active_planet = planet
	ThresholdSlider.value = active_planet.send_ship_threshold
	ThresholdText.text = str(active_planet.send_ship_threshold)

	update_menu_for_active_planet()
	popup(true)


func update_spell_button():
	SpellButton.disabled = !active_planet.can_use_skill || !player.can_use_spell
	SpellButtonText.text     =  str(active_planet.skill.spice_cost)


func update_menu_for_active_planet():
	update_spell_button()
	
	AcceleratorButtonText.text  = str(PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR))
	ShieldButtonText.text       = str(PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE))
	GeneratorButtonText.text    = str(PLANET_DATA.get_cost(PlanetData.Types.GENERATOR))
	RafineryButtonText.text     = str(PLANET_DATA.get_cost(PlanetData.Types.RAFINERY))
	LaboratoryButtonText.text   = str(PLANET_DATA.get_cost(PlanetData.Types.LABORATORY))
	
	GeneratorButton.icon   = generator_icon
	ShieldButton.icon   = shield_icon
	AcceleratorButton.icon = accel_icon
	RafineryButton.icon    = rafinery_icon
	LaboratoryButton.icon  = laboratory_icon
	
	PlanetText.text = get_planet_text()
	ExpendButton.hide()
	match active_planet.type :
		PlanetData.Types.GENERATOR : 
			GeneratorButton.icon = sell_icon
			GeneratorButtonText.text = "+" + str(PLANET_DATA.get_cost(PlanetData.Types.GENERATOR)/2)
			SpellButton.icon = spell_generator_icon
		PlanetData.Types.DEFENSIVE :
			ShieldButtonText.text = "+" + str(PLANET_DATA.get_cost(PlanetData.Types.DEFENSIVE)/2)
			ShieldButton.icon = sell_icon
			SpellButton.icon = spell_shield_icon
		PlanetData.Types.ACCELERATOR :
			AcceleratorButtonText.text = "+" + str(PLANET_DATA.get_cost(PlanetData.Types.ACCELERATOR)/2)
			AcceleratorButton.icon = sell_icon
			SpellButton.icon = spell_accel_icon
		PlanetData.Types.RAFINERY :
			RafineryButtonText.text = "+" + str(PLANET_DATA.get_cost(PlanetData.Types.RAFINERY)/2)
			RafineryButton.icon = sell_icon
			SpellButton.icon = spell_rafinery_icon
		PlanetData.Types.LABORATORY :
			LaboratoryButtonText.text = "+" + str(PLANET_DATA.get_cost(PlanetData.Types.LABORATORY)/2)
			LaboratoryButton.icon = sell_icon
			SpellButton.icon = spell_laboratory_icon
		PlanetData.Types.NORMAL :
			SpellButton.icon = spell_normal_icon

	
func get_planet_text() -> String:
	var str = ": " + str(active_planet.ship_speed_production) + "\n"
	str += ": " + str(active_planet.get_shield_capacity()) + "\n"
	str += ": " + str(player.get_tier(active_planet.type))
	return str
		
func player_close_context_menu() -> void:
	popup(false)
	
#func has_point(point) -> bool:
	#return parent_control.get_global_rect().has_point(point)

func update_planet(updated_planet):
	active_planet = updated_planet
	update_menu_for_active_planet()
	
func enable_spell_button(bol : bool):
	if(active_planet != null):
		bol = bol && active_planet.can_use_skill
	SpellButton.disabled = !bol 


func _on_h_slider_value_changed(value: float) -> void:
	ThresholdText.text = str(value)



func _on_h_slider_drag_ended(value_changed: bool) -> void:
	active_planet.send_ship_threshold = ThresholdSlider.value


func _on_expend_button_pressed() -> void:
	show_research = true
	ResearchMenu.open_research_menu(active_planet)
	ExpendButton.hide()


func _on_research_menu_research_is_closing() -> void:
	ExpendButton.show()
	show_research = false

func show_research_menu(bol : bool):
	if(bol):
		ResearchMenu.open_research_menu(active_planet)
		ExpendButton.hide()
	elif(active_planet.type == PlanetData.Types.LABORATORY):
		ResearchMenu.close_research_menu()
		ExpendButton.show()
	else:
		ResearchMenu.close_research_menu()
		ExpendButton.hide()

func _on_local_player_setup(p):
	player = p
