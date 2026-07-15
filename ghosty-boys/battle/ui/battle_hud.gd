extends Control
class_name BattleHUD

@onready var party_status: VBoxContainer = $BottomBar/PartyPanel/PartyStatus
@onready var enemy_status: VBoxContainer = $EnemyStatus

var party_labels: Array[Label] = []
var enemy_labels: Array[Label] = []

func setup(party: Array[PartyMember], enemies: Array[Dictionary]) -> void:
	for label in party_labels:
		label.queue_free()
	party_labels.clear()
	for member in party:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 8)
		party_status.add_child(label)
		party_labels.append(label)
		
	for label in enemy_labels:
		label.queue_free()
	enemy_labels.clear()
	for enemy in enemies:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 8)
		enemy_status.add_child(label)
		enemy_labels.append(label)
		
	refresh(party, enemies)
	
	
func refresh(party: Array[PartyMember], enemies: Array[Dictionary]) -> void:
	for i in party.size():
		var member := party[i]
		party_labels[i].text = "%s %d/%d" % [member.member_name, member.current_hp, member.max_hp]
		
	for i in enemies.size():
		var enemy: Dictionary = enemies[i]
		var data: EnemyData = enemy.data
		if enemy.current_hp <= 0:
			enemy_labels[i].text = "%s defeated" % data.enemy_name
		else:
			enemy_labels[i].text = "%s %d/%d" % [data.enemy_name, enemy.current_hp, data.max_hp]
