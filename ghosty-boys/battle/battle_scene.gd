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

func _ready() -> void:
	action_menu.action_chosen.connect(_on_action_chosen)
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
			print("Got rhythm result: ", pending_result.percentage)
		State.ENEMY_TURN:
			pass
		State.CHECK_END:
			pass
