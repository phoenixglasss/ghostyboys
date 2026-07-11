extends Node2D

enum State { INTRO, PLAYER_MENU, RHYTHM_CHALLENGE, RESOLVE, ENEMY_TURN, CHECK_END }
var current_state: State = State.INTRO

# test data slots. these are special, secret slots.
@export var party: Array[PartyMember]
@export var enemies: Array[EnemyData]

@onready var action_menu: ActionMenu = $ActionMenu

var acting_member_index: int = 0
var pending_attack: AttackData
var pending_result: Dictionary
var enemy_instances: Array[Dictionary] = []

func _ready() -> void:
	action_menu.action_chosen.connect(_on_action_chosen)
	_setup_enemies()
	_enter_state(State.INTRO)
	
func _on_action_chosen(attack: AttackData) -> void:
	pending_attack = attack
	_enter_state(State.RHYTHM_CHALLENGE)
	
func _enter_state(state: State) -> void:
	current_state = state
	print("Entering state: ", State.keys()[state])
	match state:
		State.INTRO:
			_enter_state(State.PLAYER_MENU)
			# until it has an intro animation to play, it just hands off to next state
		State.PLAYER_MENU:
			action_menu.display_moves(party[acting_member_index].moveset)
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
			pass

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
		var target: Dictionary = enemy_instances[0]
		target.current_hp = max(target.current_hp - amount, 0)
		print(target.data.enemy_name, " took ", amount, " damage -> ", target.current_hp, "/", target.data.max_hp)
		
	
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
