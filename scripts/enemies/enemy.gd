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
@export var follow_player_on_wander: bool = false
@export var attack: EnemyAttack
@export var min_wander_speed: float = 80
@export var max_wander_speed: float = 120
@export var min_attack_speed: float = 80
@export var max_attack_speed: float = 120
@export var required_connections: int = 1
@export var score_value: int = 1

@onready var nav_agent: NavAgent = $NavAgent

var wander_speed: float = 100
var attack_speed: float = 100
var current_state: State = State.WANDER
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: Player
var current_attach_count: int = 0
var speed_change_timer: Timer = Timer.new()


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	speed_change_timer.one_shot = false
	speed_change_timer.wait_time = 3.0
	add_child(speed_change_timer)
	speed_change_timer.timeout.connect(on_speed_change_timeout)
	speed_change_timer.start()
	SignalBus.wire_attached.connect(on_wire_attached)
	SignalBus.wire_reset.connect(on_wire_reset)
	SignalBus.game_over.connect(on_game_over)
	set_random_speeds()
	enter_wander_state()


func _process(delta: float) -> void:
	match current_state:
		State.WANDER:
			process_wander_state(delta)
		State.ATTACK:
			process_attack_state(delta)
		State.STUNNED:
			process_stun_state(delta)


func try_stun() -> bool:
	if current_attach_count >= required_connections:
		enter_stun_state()
		return true
	return false


func try_kill() -> bool:
	if current_attach_count < required_connections:
		return false
	SignalBus.enemy_killed.emit(self)
	killed.emit()
	queue_free()
	return true


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


func on_wire_attached(node: Node2D, attached_nodes: Array[Node2D]) -> void:
	if node == self and is_instance_valid(player):
		enter_attack_state()
	if self in attached_nodes:
		# Subtract 1 for self.
		current_attach_count = len(attached_nodes) - 1


func on_wire_reset() -> void:
	if current_state == State.ATTACK && !is_queued_for_deletion():
		enter_wander_state()


func on_game_over() -> void:
	enter_wander_state()


func on_speed_change_timeout() -> void:
	set_random_speeds()
	match current_state:
		State.WANDER:
			nav_agent.max_speed = wander_speed
		State.ATTACK:
			nav_agent.max_speed = attack_speed


func set_random_speeds() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	wander_speed = rng.randf_range(min_wander_speed, max_wander_speed)
	attack_speed = rng.randf_range(min_attack_speed, max_attack_speed)


func set_state(state: State) -> void:
	current_state = state
	state_changed.emit(current_state)


## ===================== Wander State =========================

func enter_wander_state() -> void:
	set_state(State.WANDER)
	attack.set_active(false)
	pick_random_wander_point()
	nav_agent.max_speed = wander_speed


func process_wander_state(delta: float) -> void:
	if follow_player_on_wander and is_instance_valid(player):
		nav_agent.set_movement_target(player.global_position)
	elif nav_agent.is_navigation_finished():
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
	nav_agent.max_speed = attack_speed


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
