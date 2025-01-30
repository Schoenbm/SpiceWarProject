extends Control


@export var spice_cost_text : Label
@export var time_cost_text : Label
@export var ship_cost_text : Label

var spice_cost : int
var time_cost : int
var ship_cost : int

@export var spice_cost_icon : Control
@export var ship_cost_icon : Control

@export var effect_text : Label

@export var acceleration_progress_bar : TextureProgressBar
@export var generator_progress_bar: TextureProgressBar
@export var shield_progress_bar: TextureProgressBar
@export var rafinery_progress_bar: TextureProgressBar
@export var network_progress_bar: TextureProgressBar

var progressions : Dictionary

@export var acceleration_button : Button
@export var generator_button: Button
@export var shield_button: Button
@export var rafinery_button: Button
@export var network_button: Button

var buttons : Dictionary

@export var research_button : Button

@export var research_panel : PanelContainer

@export var icon_green : Color
@export var icon_light_green : Color

@export var icon_red : Color
@export var icon_redlight : Color

@export var icon_yellow : Color

var active_planet : Planet

var tier0_progress = 5
var tier1_progress =  18.8
var tier2_progress = 57.6
var tier3_progress = 97

var min_progress
var max_progress

var time_spent_searching : float
var total_time_research : float
var tier_research : int

var gm : GameManager
var player : LocalPlayer

var current_research : PlanetData.Types
var current_context_menu_branch : PlanetData.Types
var is_searching : bool

signal research_is_closing()

var time
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gm = get_parent().get_parent()
	gm.local_player_setup.connect(_on_local_player_setup)
	research_panel.hide()
	buttons[PlanetData.Types.ACCELERATOR] = acceleration_button
	buttons[PlanetData.Types.GENERATOR] = generator_button
	buttons[PlanetData.Types.DEFENSIVE] = shield_button
	buttons[PlanetData.Types.RAFINERY] = rafinery_button
	buttons[PlanetData.Types.LABORATORY] = network_button
	
	progressions[PlanetData.Types.ACCELERATOR] = acceleration_progress_bar
	progressions[PlanetData.Types.GENERATOR] = generator_progress_bar
	progressions[PlanetData.Types.DEFENSIVE] = shield_progress_bar
	progressions[PlanetData.Types.RAFINERY] = rafinery_progress_bar
	progressions[PlanetData.Types.LABORATORY] = network_progress_bar
	is_searching = false
	
	current_context_menu_branch = PlanetData.Types.NORMAL #il faut mettre une valeur, autant en mettre une inutile !
	close_research_menu()

func _process(delta: float) -> void:
	if(is_searching):
		time_spent_searching += delta
		progressions[current_research].value = (time_spent_searching / total_time_research) * (max_progress - min_progress) + min_progress


func open_research_menu(planet):
	if(planet.type == PlanetData.Types.LABORATORY):
		active_planet = planet
		$CanvasLayer.show()
		$RefreshButtonsTimer.start()
		set_button_color()
		#self.set_process(true)


	
func close_research_menu():
	$CanvasLayer.hide()
	$RefreshButtonsTimer.stop()
	#self.set_process(false)



func open_research_panel(branch : PlanetData.Types):
	var labels : Array[String]
	if(player.get_tier(branch) < 3):
		labels = gm.get_branch_cost_and_effect(player, branch)
		if(labels != null):
			research_panel.show()
			spice_cost_text.text = labels[0]
			ship_cost_text.text = labels[1]
			time_cost_text.text = labels[2]

			time_cost = int(labels[2])
		
			effect_text.text = labels[3]
			
			current_context_menu_branch = branch
			#hide_empty_costs(labels)
	else:
		research_panel.hide()
	
func close_research_panel():
	research_panel.hide()

func hide_empty_costs(labels):
	if(labels[0] == "0"):
		spice_cost_icon.hide()
	else:
		spice_cost_icon.show()
	
	if(labels[1] == "0"):
		ship_cost_icon.hide()
	else:
		ship_cost_icon.show()

func set_button_color():
	var can_afford
	research_button.disabled = is_searching
	for button in buttons.values():
		if( gm.can_afford_research(player, buttons.find_key(button), active_planet)):
			if(!is_searching):
				button.add_theme_color_override("icon_normal_color", icon_green)
				button.add_theme_color_override("icon_pressed_color", icon_light_green)
			else:
				button.add_theme_color_override("icon_normal_color", icon_yellow)
				button.add_theme_color_override("icon_pressed_color", icon_yellow)
		else:
			button.add_theme_color_override("icon_normal_color", icon_red)
			button.add_theme_color_override("icon_pressed_color", icon_redlight)

		
		
func start_research():
	if(gm.buy_upgrade_tier(player, current_context_menu_branch, active_planet)):
		$ResearchTimer.start(time_cost)
		total_time_research = time_cost
		current_research = current_context_menu_branch
		is_searching = true
		time_spent_searching = 0
		match player.get_tier(current_research):
			0 :
				min_progress = tier0_progress
				max_progress = tier1_progress
			1:
				min_progress = tier1_progress
				max_progress = tier2_progress
			2:
				min_progress = tier2_progress
				max_progress = tier3_progress
				close_research_panel()
				buttons[current_research].hide()
		return true
	
	print("cant afford")
	research_button.button_pressed = false
	return false
	

func _on_refresh_buttons_timer_timeout() -> void:
	set_button_color()


func _on_research_timer_timeout() -> void:
	is_searching = false
	research_button.set_pressed_no_signal(false)
	gm.upgrade_tier(player.alliance, current_research)
	open_research_panel(current_context_menu_branch)

func research_panel_button_opened(branch : PlanetData.Types):
	if(current_context_menu_branch == branch):
		if(!is_searching && start_research()):
			close_research_menu()
			emit_signal("research_is_closing")
	else:
		open_research_panel(branch)

func _on_acceleration_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		research_panel_button_opened(PlanetData.Types.ACCELERATOR)




func _on_generator_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		research_panel_button_opened(PlanetData.Types.GENERATOR)


func _on_shield_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		research_panel_button_opened(PlanetData.Types.DEFENSIVE)


func _on_spice_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		research_panel_button_opened(PlanetData.Types.RAFINERY)


func _on_network_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		research_panel_button_opened(PlanetData.Types.LABORATORY)


func _on_research_button_toggled(toggled_on: bool) -> void:
	if(toggled_on && !is_searching):
		start_research()
	elif(!toggled_on && is_searching):
		research_button.set_pressed_no_signal(true)


func _on_button_pressed() -> void:
	close_research_menu()
	emit_signal("research_is_closing")

func _on_local_player_setup(p : Player):
	player = p
