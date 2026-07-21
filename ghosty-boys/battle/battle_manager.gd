extends Node2D
class_name BattleManager

enum State { INTRO, PLAYER_MENU, TARGET_SELECT, RHYTHM_CHALLENGE, RESOLVE, ENEMY_TURN, CHECK_END, FINALE_CHALLENGE, VICTORY, DEFEAT }
var current_state: State = State.INTRO

const PartyMemberDisplayScene := preload("res://battle/party_member_display.tscn")
const EnemyDisplayScene := preload("res://battle/enemy_display.tscn")

const PARTY_X: float = 40.0
const ENEMY_X: float = 260.0
const ROW_SPACING: float = 35.0
const FIRST_ROW_Y: float = 20.0

const TURN_INDICATOR_OFFSET: Vector2 = Vector2(0, -16)
const PLAYER_TURN_STATES: Array = [State.PLAYER_MENU, State.TARGET_SELECT, State.RHYTHM_CHALLENGE, State.RESOLVE]

var party_displays: Array[PartyMemberDisplay] = []
var post_battle_position: Vector2
var finale_triggered: bool = false
var pending_finale_target: Dictionary
var is_final_boss_victory: bool = false

@export var enemies: Array[EnemyData]

@onready var action_menu: ActionMenu = $UI/BattleHUD/BottomBar/ActionPanel/ActionMenu
@onready var target_menu: TargetMenu = $UI/BattleHUD/BottomBar/ActionPanel/TargetMenu
@onready var conductor: Conductor = $Conductor
@onready var hud: BattleHUD = $UI/BattleHUD
@onready var turn_indicator: Sprite2D = $TurnIndicator
# @onready var background: Sprite2D = $Background


@export var bgm : BGM = preload("res://audio/music/battle/battle_bgm.tres")

var party: Array[PartyMember] = []
var acting_member_index: int = 0
var pending_attack: AttackData
var pending_result: float
var enemy_instances: Array[Dictionary] = []
var pending_target
var intro_conversation: DialogueConversation
var is_tutorial_fight: bool = false
var unlocks_scrapyard_gate: bool = false
var victory_destination_scene: String = ""

func _ready() -> void:
	action_menu.action_chosen.connect(_on_action_chosen)
	target_menu.target_chosen.connect(_on_target_chosen)
	
	action_menu.clear()
	target_menu.clear()
	
	party = GameState.party
	
	conductor.current_bgm = bgm
	
	if GameState.pending_encounter:
		enemies = GameState.pending_encounter.enemies
		# _set_background(GameState.pending_encounter.background)
		intro_conversation = GameState.pending_encounter.intro_conversation
		is_tutorial_fight = GameState.pending_encounter.is_tutorial_fight
		post_battle_position = GameState.pending_encounter.post_battle_position
		unlocks_scrapyard_gate = GameState.pending_encounter.unlocks_scrapyard_gate
		victory_destination_scene = GameState.pending_encounter.victory_destination_scene
		is_final_boss_victory = GameState.pending_encounter.is_final_boss_victory
		GameState.pending_encounter = null
	
	if conductor:
		conductor.bpm = bgm.bpm
		conductor.audio_player.stream = bgm.audio
		conductor.audio_player.play()
		conductor.battle_manager = self
		
	_setup_enemies()
	_spawn_combatants()
	hud.setup(party)
	
	if intro_conversation:
		DialogueBox.start_conversation(intro_conversation)
		await DialogueBox.conversation_finished
		
	_enter_state(State.INTRO)
	
	
func _on_action_chosen(attack: AttackData) -> void:
	action_menu.clear()
	pending_attack = attack
	if attack.target_type in ["all_enemies", "all_allies"]:
		_enter_state(State.RHYTHM_CHALLENGE)
	else:
		_enter_state(State.TARGET_SELECT)
		
func _update_turn_indicator() -> void:
	if current_state in PLAYER_TURN_STATES and acting_member_index < party_displays.size():
		turn_indicator.visible = true
		turn_indicator.position = party_displays[acting_member_index].position + TURN_INDICATOR_OFFSET
	else:
		turn_indicator.visible = false
	
func _enter_state(state: State) -> void:
	current_state = state
	print("Entering state: ", State.keys()[state])
	_update_turn_indicator()
	match state:
		State.INTRO:
			_enter_state(State.PLAYER_MENU)
			# until it has an intro animation to play, it just hands off to next state
		State.PLAYER_MENU:
			action_menu.display_moves(party[acting_member_index].moveset)
		State.TARGET_SELECT:
			var candidates: Array
			if pending_attack.target_type == "single_ally":
				candidates = party.filter(func(member): return member.current_hp > 0)
			else:
				candidates = enemy_instances.filter(func(enemy): return enemy.current_hp > 0)
			
			if candidates.size() == 1:
				pending_target = candidates[0]
				_enter_state(State.RHYTHM_CHALLENGE)
			else:
				target_menu.display_targets(candidates)
		State.RHYTHM_CHALLENGE:
			conductor.play_chart(pending_attack)
			pending_result = await conductor.chart_completed
			_enter_state(State.RESOLVE)
		State.RESOLVE:
			_resolve_action()
			_after_resolve()
		State.ENEMY_TURN:
			_run_enemy_turn()
		State.CHECK_END:
			_check_battle_end()
		State.VICTORY:
			print("Victory, wooooh!")
			if GameState.pending_trigger_id != "":
				GameState.mark_trigger_cleared(GameState.pending_trigger_id)
				GameState.pending_trigger_id = ""
			if is_tutorial_fight:
				GameState.tutorial_fight_won = true
				GameState.return_position = post_battle_position
			if unlocks_scrapyard_gate:
				GameState.scrapyard_gate_won = true
			if is_final_boss_victory:
				GameState.final_boss_defeated = true
			await get_tree().create_timer(1.0).timeout
			if victory_destination_scene != "":
				SceneTransition.fade_to_scene(victory_destination_scene)
			else:
				SceneTransition.return_to_overworld()
		State.FINALE_CHALLENGE:
			_run_finale()
		State.DEFEAT:
			print("Defeat... So sad.")
			_reset_party_hp()
			GameState.pending_trigger_id = ""
			await get_tree().create_timer(1.0).timeout
			SceneTransition.return_to_overworld()

func _setup_enemies() -> void:
	for i in enemies.size():
		enemy_instances.append({
			"data": enemies[i],
			"current_hp": enemies[i].max_hp,
			"id": "enemy_%d" % i
		})

# damage math portion
func _resolve_action() -> void:
	var amount := roundi(pending_attack.base_power * pending_result)
	
	if pending_attack.is_healing:
		if pending_attack.target_type == "all_allies":
			_apply_healing_to_all_allies(amount)
		else:
			var target := pending_target as PartyMember
			target.current_hp = min(target.current_hp + amount, target.max_hp)
			print(target.member_name, " healed for ", amount, " -> ", target.current_hp, "/", target.max_hp)
	elif pending_attack.target_type == "all_enemies":
		_apply_damage_to_all_enemies(amount)
	else:
		_apply_damage_to_target(pending_target, amount)
	
	hud.refresh(party)
	
func _after_resolve() -> void:
	if finale_triggered:
		_enter_state(State.FINALE_CHALLENGE)
		return

	if enemy_instances.all(func(enemy): return enemy.current_hp <= 0):
		_enter_state(State.CHECK_END)
		return

	var next_index := _find_next_living_member(acting_member_index + 1)
	if next_index != -1:
		acting_member_index = next_index
		_enter_state(State.PLAYER_MENU)
	else:
		acting_member_index = 0
		_enter_state(State.ENEMY_TURN)
		
		
func _run_enemy_turn() -> void:
	for enemy in enemy_instances:
		if enemy.current_hp <= 0:
			continue
			
		var living_party := party.filter(func(member): return member.current_hp > 0)
		if living_party.is_empty():
			_enter_state(State.CHECK_END)
			return
			
		var move: AttackData = enemy.data.moveset.pick_random()
		var target: PartyMember = living_party.pick_random()
		
		target.current_hp = max(target.current_hp - move.base_power, 0)
		print(enemy.data.enemy_name, " used ", move.attack_name, " on ", target.member_name, " -> ", target.current_hp, "/", target.max_hp)
		hud.refresh(party)
		
		await get_tree().create_timer(0.4).timeout
		
	_enter_state(State.CHECK_END)

func _check_battle_end() -> void:
	var all_enemies_dead := enemy_instances.all(func(enemy): return enemy.current_hp <= 0)
	if all_enemies_dead:
		_enter_state(State.VICTORY)
		return
		
	var all_party_dead := party.all(func(member): return member.current_hp <= 0)
	if all_party_dead:
		_enter_state(State.DEFEAT)
		return
		
	var next_index := _find_next_living_member(0)
	acting_member_index = next_index
	_enter_state(State.PLAYER_MENU)
	
func _on_target_chosen(target) -> void:
	target_menu.clear()
	pending_target = target
	_enter_state(State.RHYTHM_CHALLENGE)
	

func _find_next_living_member(start_index: int) -> int:
	var index := start_index
	while index < party.size():
		if party[index].current_hp > 0:
			return index
		index += 1
	return -1


func _spawn_combatants() -> void:
	for i in party.size():
		var display: PartyMemberDisplay = PartyMemberDisplayScene.instantiate()
		add_child(display)
		display.position = Vector2(PARTY_X, FIRST_ROW_Y + i * ROW_SPACING)
		display.setup(party[i])
		display.conductor = conductor
		party_displays.append(display)
		
	for i in enemy_instances.size():
		var display: EnemyDisplay = EnemyDisplayScene.instantiate()
		add_child(display)
		display.position = Vector2(ENEMY_X, FIRST_ROW_Y + i * ROW_SPACING)
		display.setup(enemy_instances[i].data)
		display.conductor = conductor
		enemy_instances[i]["display"] = display
	
func _set_background(texture: Texture2D) -> void:
	pass
	# if texture:
		# background.texture = texture
		# background.scale = Vector2(320.0 / texture.get_width(), 180.0 / texture.get_height())

func _apply_damage_to_target(target: Dictionary, amount: int) -> void:
	if finale_triggered:
		return
	var data: EnemyData = target.data
	target.current_hp = max(target.current_hp - amount, 0)
	print(data.enemy_name, " took ", amount, " damage -> ", target.current_hp, "/", data.max_hp)

	if data.finale_threshold > 0 and not finale_triggered and target.current_hp <= data.finale_threshold:
		finale_triggered = true
		target.current_hp = data.finale_threshold
		pending_finale_target = target
		return

	if target.current_hp <= 0:
		GameState.log_defeat(data.enemy_name, "banish", data.zone_theme)
		print(data.enemy_name, " was Banished!")
		target.display.visible = false
		
func _apply_damage_to_all_enemies(amount: int) -> void:
	for enemy in enemy_instances:
		if enemy.current_hp <= 0:
			continue
		_apply_damage_to_target(enemy, amount)

func _apply_healing_to_all_allies(amount: int) -> void:
	for member in party:
		if member.current_hp <= 0:
			continue
		member.current_hp = min(member.current_hp + amount, member.max_hp)
		print(member.member_name, " healed for ", amount, " -> ", member.current_hp, "/", member.max_hp)

func _run_finale() -> void:
	var target: Dictionary = pending_finale_target
	var data: EnemyData = target.data

	conductor.play_finale(data.finale_chart)
	await conductor.chart_completed

	_finish_finale_target(target)


func _finish_finale_target(target: Dictionary) -> void:
	var data: EnemyData = target.data
	target.current_hp = 0
	GameState.log_defeat(data.enemy_name, "banish", data.zone_theme)
	print(data.enemy_name, " was Banished!")
	target.display.visible = false
	hud.refresh(party)
	_enter_state(State.CHECK_END)
	
func _reset_party_hp() -> void:
	for member in party:
		member.current_hp = member.max_hp
