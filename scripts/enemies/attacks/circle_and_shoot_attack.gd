extends EnemyAttack

@export var nav_agent: NavAgent
@export var projectile_shooter: ProjectileShooter

@onready var rand_target: RandomlyRotatingTarget = $RandomlyRotatingTarget

var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	var enemy: Enemy = get_parent()
	enemy.killed.connect(on_enemy_killed)


func _process(delta: float) -> void:
	if is_active:
		nav_agent.set_movement_target(rand_target.target.global_position)
		projectile_shooter.shoot_direction = (player.global_position - global_position).normalized()


func set_active(active: bool) -> void:
	super.set_active(active)
	projectile_shooter.set_active(active)



func on_enemy_killed() -> void:
	rand_target.queue_free() # This needs to be queued separately because it reparents itself.
