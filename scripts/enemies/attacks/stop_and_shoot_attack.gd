extends EnemyAttack

enum State
{
	CHASING = 0,
	STOPPED = 1,
	CHARGING = 2
}

@export var stop_distance: float = 150
@export var charge_time: float = 0.5
@export var time_between_shots: float = 1.0
@export var nav_agent: NavAgent
@export var projectile_shooter: ProjectileShooter

var player: Player
var time_since_last_shot: float = 100
var current_state: State = State.CHASING
var time_in_state: float = 0


func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player")


func init() -> void:
	# Doing this so enemy immediately starts shooting.
	current_state = State.CHARGING
	time_since_last_shot = 100


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
			if time_since_last_shot >= (time_between_shots - charge_time):
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
				else:
					change_state(State.CHASING)

	time_since_last_shot += delta
	time_in_state += delta


func is_in_firing_distance() -> bool:
	return global_position.distance_squared_to(player.global_position) <= stop_distance * stop_distance


func fire_projectile() -> void:
	projectile_shooter.shoot_direction = (player.global_position - global_position).normalized()
	projectile_shooter.shoot_immediately()


func change_state(new_state: State):
	current_state = new_state
	time_in_state = 0
