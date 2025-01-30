extends HBoxContainer

class_name LobbyPlayerData

@export var AllianceOptions : OptionButton
@export var AllianceLabel : Label
@export var PseudoLabel : Label
@export var idLabel : Label
@export var check : Control

func _ready():
	self.hide()


func init(pd : PlayerData):
	if(pd == null):
		return
	if(pd.player_id == LocalPlayerData.player_id):
		AllianceLabel.hide()
		AllianceOptions.show()
		PseudoLabel.text = LocalPlayerData.player_name
		idLabel.text = str(LocalPlayerData.player_id)
	else:
		AllianceLabel.show()
		AllianceLabel.text = PlanetType.get_alliance_name(pd.player_alliance)
		AllianceOptions.hide()
		PseudoLabel.text = pd.player_name
		idLabel.text = str(pd.player_id)

	show()

func color_player_ready(bol):
	print(self.name + str(bol) + " : " +PseudoLabel.text)
	if(bol):
		check.modulate = Color(0.7,1.0,0.7)
	else:
		check.modulate = Color(1.0,1.0,1.0)
		
func clear():
	hide()
