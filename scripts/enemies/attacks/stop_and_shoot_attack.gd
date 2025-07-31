extends EnemyAttack

@export var stop_distance: float = 150
@export var charge_time: float = 1
@export var nav_agent: NavAgent
@export var projectile_shooter: ProjectileShooter

var player: Player
var is_firing_projectile: bool
var timer: Timer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)


func _process(delta: float) -> void:
	if !is_active or is_firing_projectile or !is_instance_valid(player):
		return

	if global_position.distance_squared_to(player.global_position) > stop_distance * stop_distance:
		nav_agent.set_movement_target(player.global_position)
	else:
		nav_agent.set_movement_target(global_position)
		fire_projectile()


func fire_projectile() -> void:
	is_firing_projectile = true
	timer.start(charge_time)
	await timer.timeout
	if !is_instance_valid(player):
		return
	projectile_shooter.shoot_direction = (player.global_position - global_position).normalized()
	projectile_shooter.shoot()
	is_firing_projectile = false
