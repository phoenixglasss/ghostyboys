extends Control
class_name BattleHUD

@onready var party_status: VBoxContainer = $BottomBar/PartyPanel/PartyStatus

var party_labels: Array[Label] = []
var enemy_labels: Array[Label] = []

func setup(party: Array[PartyMember]) -> void:
	for label in party_labels:
		label.queue_free()
	party_labels.clear()
	for member in party:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 8)
		party_status.add_child(label)
		party_labels.append(label)
		
	refresh(party)
	
func refresh(party: Array[PartyMember]) -> void:
	for i in party.size():
		var member := party[i]
		party_labels[i].text = "%s %d/%d" % [member.member_name, member.current_hp, member.max_hp]
