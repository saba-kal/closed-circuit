extends Area2D

@export var wire_line: Line2D

var attached_bodies: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(on_body_entered)
	reset_wire()


func _process(_delta: float) -> void:
	for i in range(len(attached_bodies)):
		wire_line.points[i] = attached_bodies[i].global_position


func on_body_entered(body: Node2D) -> void:

	if len(attached_bodies) >= 3 && attached_bodies[0] == body:
		kill_enemies()
		reset_wire()
	elif body not in attached_bodies:
		attached_bodies.insert(len(attached_bodies) - 1, body)
		wire_line.add_point(Vector2.ZERO)
		SignalBus.wire_attached.emit(body)


func kill_enemies() -> void:
	for body in attached_bodies:
		if body is Enemy:
			body.kill()


func reset_wire() -> void:
	attached_bodies = [get_parent()] # Player is always attached
	wire_line.points = [Vector2.ZERO]
