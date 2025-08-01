extends EnemyAttack

@export var stop_distance: float = 150
@export var windup_time: float = 1.0
@export var charge_time: float = 0.5
@export var charge_speed: float = 800
@export var damage: int = 1
@export var nav_agent: NavAgent
@export var charge_visuals: Node2D

@onready var area: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player: Player
var enemy: Enemy
var is_winding_up: bool
var is_charging: bool
var windup_timer: Timer
var charge_timer: Timer
var direction: Vector2


func _ready() -> void:
	super._ready()
	charge_visuals.visible = false
	area.body_entered.connect(on_body_entered)
	player = get_tree().get_first_node_in_group("player")
	enemy = get_parent()
	windup_timer = Timer.new()
	windup_timer.one_shot = true
	add_child(windup_timer)
	charge_timer = Timer.new()
	charge_timer.one_shot = true
	add_child(charge_timer)


func init() -> void:
	is_winding_up = false
	is_charging = false


func _process(delta: float) -> void:
	if !is_active or is_winding_up or is_charging or !is_instance_valid(player):
		return
	if global_position.distance_squared_to(player.global_position) > stop_distance * stop_distance:
		nav_agent.set_movement_target(player.global_position)
	else:
		nav_agent.set_movement_target(global_position)
		charge()


func _physics_process(delta: float) -> void:
	if !is_active or !is_charging:
		return
	var collision = enemy.move_and_collide(direction * charge_speed * delta)
	if collision:
		is_charging = false
		charge_timer.stop()
		charge_visuals.visible = false


func charge() -> void:
	is_winding_up = true
	attack_charge_effect.emitting = true
	windup_timer.start(windup_time)
	await windup_timer.timeout
	is_winding_up = false
	attack_charge_effect.emitting = false
	if !is_instance_valid(player):
		return
	is_charging = true
	audio_stream_player.play()
	charge_visuals.visible = true
	direction = (player.global_position - global_position).normalized()
	charge_timer.start(charge_time)
	await charge_timer.timeout
	is_charging = false
	charge_visuals.visible = false


func on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and is_charging:
		body.take_damage(damage)
