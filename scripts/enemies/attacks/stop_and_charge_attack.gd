extends EnemyAttack

enum State {
	CHASING = 0,
	WINDUP = 1,
	CHARGING = 2
}

@export var stop_distance: float = 150
@export var time_between_charges: float = 1.0
@export var windup_time: float = 1.0
@export var charge_time: float = 0.5
@export var charge_speed: float = 800
@export var damage: int = 1
@export var nav_agent: NavAgent
@export var charge_visuals: Node2D

@onready var area: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var rand_target: RandomlyRotatingTarget = $RandomlyRotatingTarget

var player: Player
var enemy: Enemy
var direction: Vector2
var current_state: State = State.CHASING
var time_in_state: float = 0


func _ready() -> void:
	super._ready()
	charge_visuals.visible = false
	area.body_entered.connect(on_body_entered)
	player = get_tree().get_first_node_in_group("player")
	enemy = get_parent()
	enemy.killed.connect(on_enemy_killed)


func _physics_process(delta: float) -> void:
	if !is_active or !is_instance_valid(player):
		return

	match current_state:
		State.CHASING:
			nav_agent.set_movement_target(rand_target.target.global_position)
			if time_in_state >= time_between_charges and target_reached():
				change_state(State.WINDUP)
		State.WINDUP:
			nav_agent.set_movement_target(global_position)
			attack_charge_effect.emitting = true
			if time_in_state >= windup_time:
				change_state(State.CHARGING)
				attack_charge_effect.emitting = false
				direction = (player.global_position - global_position).normalized()
		State.CHARGING:
			charge_visuals.visible = true
			var collision = enemy.move_and_collide(direction * charge_speed * delta)
			if collision or time_in_state >= charge_time:
				change_state(State.CHASING)
				charge_visuals.visible = false
	time_in_state += delta


func change_state(state: State) -> void:
	current_state = state
	time_in_state = 0


func target_reached() -> bool:
	return player.global_position.distance_squared_to(global_position) < stop_distance * stop_distance


func on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and current_state == State.CHARGING:
		body.take_damage(damage)


func on_enemy_killed() -> void:
	rand_target.queue_free() # This needs to be queued separately because it reparents itself.
