extends Node2D

enum State { INTRO, PLAYER_MENU, TARGET_SELECT, RHYTHM_CHALLENGE, RESOLVE, ENEMY_TURN, CHECK_END, VICTORY, DEFEAT }
var current_state: State = State.INTRO

# test data slots. these are special, secret slots.
@export var party: Array[PartyMember]
@export var enemies: Array[EnemyData]

@onready var action_menu: ActionMenu = $ActionMenu
@onready var target_menu: TargetMenu = $TargetMenu

var acting_member_index: int = 0
var pending_attack: AttackData
var pending_result: Dictionary
var enemy_instances: Array[Dictionary] = []
var pending_target: Dictionary

func _ready() -> void:
	action_menu.action_chosen.connect(_on_action_chosen)
	target_menu.target_chosen.connect(_on_target_chosen)
	_setup_enemies()
	_enter_state(State.INTRO)
	
func _on_action_chosen(attack: AttackData) -> void:
	action_menu.clear()
	pending_attack = attack
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
			action_menu.display_moves(party[acting_member_index].moveset)
		State.TARGET_SELECT:
			var living_enemies := enemy_instances.filter(func(enemy): return enemy.current_hp > 0)
			if living_enemies.size() == 1:
				pending_target = living_enemies[0]
				_enter_state(State.RHYTHM_CHALLENGE)
			else:
				target_menu.display_targets(living_enemies)
		State.RHYTHM_CHALLENGE:
			RhythmMinigame.start_challenge(pending_attack.attack_name)
			pending_result = await RhythmMinigame.challenge_completed
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
	var amount := roundi(pending_attack.base_power * pending_result.percentage)
	
	if pending_attack.is_healing:
		var target: PartyMember = party[acting_member_index]
		target.current_hp = min(target.current_hp + amount, target.max_hp)
		print(target.member_name, " healed for ", amount, " -> ", target.current_hp, "/", target.max_hp)
	else:
		pending_target.current_hp = max(pending_target.current_hp - amount, 0)
		print(pending_target.data.enemy_name, " took ", amount, " damage -> ", pending_target.current_hp, "/", pending_target.data.max_hp)
		
	
func _after_resolve() -> void:
	acting_member_index += 1
	if acting_member_index < party.size():
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
		
	_enter_state(State.PLAYER_MENU)
	
func _on_target_chosen(enemy: Dictionary) -> void:
	target_menu.clear()
	pending_target = enemy
	_enter_state(State.RHYTHM_CHALLENGE)
