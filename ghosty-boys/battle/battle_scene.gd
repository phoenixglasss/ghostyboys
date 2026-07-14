extends Node2D

enum State { INTRO, PLAYER_MENU, TARGET_SELECT, RHYTHM_CHALLENGE, RESOLVE, ENEMY_TURN, CHECK_END, VICTORY, DEFEAT }
var current_state: State = State.INTRO

@export var enemies: Array[EnemyData]

@onready var action_menu: ActionMenu = $UI/ActionMenu
@onready var target_menu: TargetMenu = $UI/TargetMenu
@onready var conductor: Conductor = $Conductor
@onready var hud: BattleHUD = $UI/BattleHUD

var party: Array[PartyMember] = []
var acting_member_index: int = 0
var pending_attack: AttackData
var pending_result: float
var enemy_instances: Array[Dictionary] = []
var pending_target: Dictionary
var is_destroy_action: bool = false

func _ready() -> void:
	action_menu.action_chosen.connect(_on_action_chosen)
	action_menu.destroy_chosen.connect(_on_destroy_chosen)
	target_menu.target_chosen.connect(_on_target_chosen)
	
	party = GameState.party
	
	if GameState.pending_encounter:
		enemies = GameState.pending_encounter.enemies
		GameState.pending_encounter = null
		
	_setup_enemies()
	hud.setup(party, enemy_instances)
	_enter_state(State.INTRO)
	
func _on_action_chosen(attack: AttackData) -> void:
	action_menu.clear()
	pending_attack = attack
	is_destroy_action = false
	if attack.is_healing:
		_enter_state(State.RHYTHM_CHALLENGE)
	else:
		_enter_state(State.TARGET_SELECT)
	
func _enter_state(state: State) -> void:
	current_state = state
	print("Entering state: ", State.keys()[state])
	match state:
		State.INTRO:
			_enter_state(State.PLAYER_MENU)
			# until it has an intro animation to play, it just hands off to next state
		State.PLAYER_MENU:
			print("Now acting: ", party[acting_member_index].member_name)
			action_menu.display_moves(party[acting_member_index].moveset, _is_destroy_available())
		State.TARGET_SELECT:
			var eligible_enemies: Array
			if is_destroy_action:
				eligible_enemies = _get_eligible_targets()
			else:
				eligible_enemies = enemy_instances.filter(func(enemy): return enemy.current_hp > 0)
			if eligible_enemies.size() == 1:
				pending_target = eligible_enemies[0]
				_on_target_locked_in()
			else:
				target_menu.display_targets(eligible_enemies)
		State.RHYTHM_CHALLENGE:
			conductor.play_chart(pending_attack.chart)
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
			print("Victory!")
			await get_tree().create_timer(1.0).timeout
			SceneTransition.return_to_overworld()
		State.DEFEAT:
			print("Defeat...")

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
		var target: PartyMember = party[acting_member_index]
		target.current_hp = min(target.current_hp + amount, target.max_hp)
		print(target.member_name, " healed for ", amount, " -> ", target.current_hp, "/", target.max_hp)
	else:
		pending_target.current_hp = max(pending_target.current_hp - amount, 0)
		print(pending_target.data.enemy_name, " took ", amount, " damage -> ", pending_target.current_hp, "/", pending_target.data.max_hp)
		
		if pending_target.current_hp <= 0:
			GameState.log_defeat(pending_target.data.enemy_name, "banish", pending_target.data.zone_theme)
			print(pending_target.data.enemy_name, " was Banished!")
	
	hud.refresh(party, enemy_instances)
	
func _after_resolve() -> void:
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
		hud.refresh(party, enemy_instances)
		
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
	
func _on_target_chosen(enemy: Dictionary) -> void:
	target_menu.clear()
	pending_target = enemy
	_on_target_locked_in()
	
	
func _get_eligible_targets() -> Array:
	var eligible: Array = []
	for enemy in enemy_instances:
		if enemy.current_hp <= 0:
			continue
		var data: EnemyData = enemy.data
		var ratio := float(enemy.current_hp) / data.max_hp
		if ratio <= data.destroy_threshold:
			eligible.append(enemy)
	return eligible
	
func _is_destroy_available() -> bool:
	return not _get_eligible_targets().is_empty()
	
	
func _on_target_locked_in() -> void:
	if is_destroy_action:
		_finish_enemy()
	else:
		_enter_state(State.RHYTHM_CHALLENGE)

func _finish_enemy() -> void:
	GameState.log_defeat(pending_target.data.enemy_name, "destroy", pending_target.data.zone_theme)
	pending_target.current_hp = 0
	print(pending_target.data.enemy_name, " was Destroyed!")
	hud.refresh(party, enemy_instances)
	is_destroy_action = false
	_after_resolve()

func _on_destroy_chosen() -> void:
	action_menu.clear()
	is_destroy_action = true
	_enter_state(State.TARGET_SELECT)

func _find_next_living_member(start_index: int) -> int:
	var index := start_index
	while index < party.size():
		if party[index].current_hp > 0:
			return index
		index += 1
	return -1
