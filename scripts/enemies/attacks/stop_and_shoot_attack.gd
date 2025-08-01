extends EnemyAttack

enum State
{
	CHASING = 0,
	STOPPED = 1,
	CHARGING = 2
}

@export var stop_distance: float = 150
@export var stop_time: float = 1.5
@export var charge_time: float = 0.5
@export var time_between_shots: float = 1.0
@export var nav_agent: NavAgent
@export var projectile_shooter: ProjectileShooter

var player: Player
var is_firing_projectile: bool
var time_since_last_shot: float = 0
var stop_timer: Timer = Timer.new()
var charge_timer: Timer = Timer.new()
var current_state: State = State.CHASING
var time_in_state: float = 0


func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player")
	stop_timer.one_shot = true
	add_child(stop_timer)
	charge_timer.one_shot = true
	add_child(charge_timer)


func _process(delta: float) -> void:
	if !is_active or !is_instance_valid(player):
		return
	
	match current_state:
		State.CHASING:
			nav_agent.set_movement_target(player.global_position)
			if is_in_firing_distance():
				change_state(State.STOPPED)
		State.STOPPED:
			nav_agent.set_movement_target(global_position)
			if time_in_state >= stop_time:
				change_state(State.CHARGING)
		State.CHARGING:
			nav_agent.set_movement_target(global_position)
			attack_charge_effect.emitting = true
			if time_in_state >= charge_time && time_since_last_shot >= time_between_shots:
				fire_projectile()
				time_since_last_shot = 0
				attack_charge_effect.emitting = false
				if is_in_firing_distance():
					change_state(State.STOPPED)
					# This is so that they can immediately start shooting again. 
					time_in_state = max(time_between_shots - charge_time, 0)
				else:
					change_state(State.CHASING)

	time_since_last_shot += delta
	time_in_state += delta


func is_in_firing_distance() -> bool:
	return global_position.distance_squared_to(player.global_position) <= stop_distance * stop_distance


func fire_projectile() -> void:
	projectile_shooter.shoot_direction = (player.global_position - global_position).normalized()
	projectile_shooter.shoot_immediately()
	is_firing_projectile = false


func change_state(new_state: State):
	current_state = new_state
	time_in_state = 0
