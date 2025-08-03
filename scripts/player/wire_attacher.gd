class_name WireAttacher extends Area2D

@export var wire_line: Line2D
@export var target_indicator: Node2D
@export var connect_self: bool = true
@export var manually_attach: bool = false

@onready var wire_attached_sound: AudioStreamPlayer = $WireAttachedSound

var attached_bodies: Array[Node2D] = []
var wire_can_be_used: bool = true
var stun_duration_timer: Timer


func _ready() -> void:
	target_indicator.visible = false
	body_entered.connect(on_body_entered)
	stun_duration_timer = Timer.new()
	stun_duration_timer.one_shot = true
	add_child(stun_duration_timer)
	reset_wire()


func _process(delta: float) -> void:
	for i in range(len(attached_bodies)):
		wire_line.points[i] = attached_bodies[i].global_position
	if len(attached_bodies) > 1:
		target_indicator.global_position = attached_bodies[0].global_position
	target_indicator.rotate(delta)


func on_body_entered(body: Node2D) -> void:
	if body is Enemy and not manually_attach:
		attach_enemy(body)


func attach_enemy(enemy: Enemy) -> void:
	if len(attached_bodies) >= 3 && attached_bodies[0] == enemy:
		if connect_self:
			attached_bodies[-1] = enemy
		else:
			attached_bodies.append(enemy)
			wire_line.add_point(enemy.global_position)
		wire_can_be_used = false
		stun_enemies()
		stun_duration_timer.start(0.5)
		await stun_duration_timer.timeout
		kill_enemies()
		reset_wire()
	elif wire_can_be_used and enemy not in attached_bodies:
		if connect_self:
			attached_bodies.insert(len(attached_bodies) - 1, enemy)
		else:
			attached_bodies.append(enemy)
		wire_line.add_point(Vector2.ZERO)
		SignalBus.wire_attached.emit(enemy, attached_bodies)
		if len(attached_bodies) > 1:
			wire_attached_sound.play()
		if len(attached_bodies) > 2:
			target_indicator.visible = true


func stun_enemies() -> void:
	var enemies: Array[Enemy] = []
	for body in attached_bodies:
		if body is Enemy and body not in enemies:
			if body.try_stun():
				enemies.append(body)
	SignalBus.enemies_stunned.emit(enemies)


func kill_enemies() -> void:
	var enemies_killed: Array[Enemy]
	for body in attached_bodies:
		if body is Enemy:
			if body.try_kill() and body not in enemies_killed:
				enemies_killed.append(body)
	SignalBus.enemies_killed.emit(enemies_killed)


func reset_wire() -> void:
	if connect_self:
		attached_bodies = [get_parent()] # Player is always attached
		wire_line.points = [Vector2.ZERO]
	else:
		attached_bodies = []
		wire_line.points = []
	wire_can_be_used = true
	target_indicator.visible = false
	SignalBus.wire_reset.emit()
