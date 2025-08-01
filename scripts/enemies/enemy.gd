class_name Enemy extends CharacterBody2D

signal state_changed(new_state: State)
signal killed()

enum State
{
	WANDER = 0,
	ATTACK = 1,
	STUNNED = 2
}

@export var min_wander_path_distance: float = 20
@export var max_wander_path_distance: float = 100
@export var attack: EnemyAttack

@onready var nav_agent: NavAgent = $NavAgent

var current_state: State = State.WANDER
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	SignalBus.wire_attached.connect(on_wire_attached)
	SignalBus.game_over.connect(on_game_over)
	enter_wander_state()


func _process(delta: float) -> void:
	match current_state:
		State.WANDER:
			process_wander_state(delta)
		State.ATTACK:
			process_attack_state(delta)
		State.STUNNED:
			process_stun_state(delta)


func stun() -> void:
	enter_stun_state()


func kill() -> void:
	SignalBus.enemy_killed.emit(self)
	killed.emit()
	queue_free()


func get_random_direction() -> Vector2:
	var randi: int = rng.randi_range(0, 7)
	return [
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(0, -1),
		Vector2(-1, 0)
	][randi].normalized()


func on_wire_attached(node: Node2D) -> void:
	if node == self:
		enter_attack_state()


func on_game_over() -> void:
	enter_wander_state()


func set_state(state: State) -> void:
	current_state = state
	state_changed.emit(current_state)


## ===================== Wander State =========================

func enter_wander_state() -> void:
	set_state(State.WANDER)
	attack.set_active(false)
	pick_random_wander_point()


func process_wander_state(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		pick_random_wander_point()

func pick_random_wander_point() -> void:
	var wander_direction: Vector2 = get_random_direction()
	var wander_path_distance: float = rng.randf_range(min_wander_path_distance, max_wander_path_distance)
	nav_agent.set_movement_target(global_position + wander_direction * wander_path_distance)

## ==========================================================

## ===================== Attack State =========================

func enter_attack_state() -> void:
	set_state(State.ATTACK)
	attack.set_active(true)
	attack.init()


func process_attack_state(_delta: float) -> void:
	pass # nothing to do

## ==========================================================

## ===================== Stun State =========================

func enter_stun_state() -> void:
	set_state(State.STUNNED)
	attack.set_active(false)
	nav_agent.set_movement_target(global_position)


func process_stun_state(_delta: float) -> void:
	pass # nothing to do

## ==========================================================
