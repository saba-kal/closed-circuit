extends Label

@export var enemy: Enemy
@export var zero_color: Color = Color.YELLOW


func _ready() -> void:
	display_count(enemy.required_connections)
	SignalBus.wire_attached.connect(on_wire_attached)
	SignalBus.wire_reset.connect(on_wire_reset)


func display_count(count: int) -> void:
	text = "%02d" % max(count, 0)
	if count <= 0:
		modulate = zero_color
		self_modulate = zero_color * 2
	else:
		modulate = Color.WHITE
		self_modulate = Color.WHITE


func on_wire_attached(node: Node2D, attached_nodes: Array[Node2D]) -> void:
	if enemy == node or enemy in attached_nodes:
		display_count(enemy.required_connections - len(attached_nodes) + 1)


func on_wire_reset() -> void:
	display_count(enemy.required_connections)
