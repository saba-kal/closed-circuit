extends EnemyAttack

@export var stop_distance: float = 150
@export var charge_time: float = 0.5
@export var time_between_shots: float = 1.0
@export var nav_agent: NavAgent
@export var projectile_shooter: ProjectileShooter

var player: Player
var is_firing_projectile: bool
var time_since_last_shot: float = 0
var timer: Timer = Timer.new()


func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group("player")
	timer.one_shot = true
	add_child(timer)


func _process(delta: float) -> void:
	if !is_active or is_firing_projectile or !is_instance_valid(player):
		return

	if global_position.distance_squared_to(player.global_position) > stop_distance * stop_distance:
		nav_agent.set_movement_target(player.global_position)
	else:
		nav_agent.set_movement_target(global_position)
		if time_since_last_shot >= time_between_shots:
			fire_projectile()
			time_since_last_shot = 0
	time_since_last_shot += delta


func fire_projectile() -> void:
	is_firing_projectile = true
	attack_charge_effect.emitting = true
	timer.start(charge_time)
	await timer.timeout
	projectile_shooter.shoot_direction = (player.global_position - global_position).normalized()
	projectile_shooter.shoot_immediately()
	attack_charge_effect.emitting = false
	is_firing_projectile = false
