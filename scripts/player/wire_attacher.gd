extends Area2D

@export var wire_line: Line2D
@export var target_indicator: Node2D

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
	if body is not Enemy:
		return
	if len(attached_bodies) >= 3 && attached_bodies[0] == body:
		attached_bodies[-1] = body
		wire_can_be_used = false
		stun_enemies()
		stun_duration_timer.start(0.5)
		await stun_duration_timer.timeout
		kill_enemies()
		reset_wire()
	elif wire_can_be_used and body not in attached_bodies:
		attached_bodies.insert(len(attached_bodies) - 1, body)
		wire_line.add_point(Vector2.ZERO)
		SignalBus.wire_attached.emit(body, attached_bodies)
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
	attached_bodies = [get_parent()] # Player is always attached
	wire_line.points = [Vector2.ZERO]
	wire_can_be_used = true
	target_indicator.visible = false
	SignalBus.wire_reset.emit()
