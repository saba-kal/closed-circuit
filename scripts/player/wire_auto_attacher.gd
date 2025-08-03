extends Node2D

@export var enemies_container: Node
@export var time_between_connections: float = 1
@export var max_connection_count: int = 3
@export var wire: Line2D
@export var wire_attacher: WireAttacher

var attached_enemies: Array[Node2D] = []
var time_since_last_connect: float = 0


func _ready() -> void:
	SignalBus.enemies_killed.connect(on_enemies_killed)


func _process(delta: float) -> void:
	if time_since_last_connect >= time_between_connections:
		if (len(attached_enemies) >= max_connection_count and 
			wire_attacher.wire_can_be_used and 
			is_instance_valid(attached_enemies[0])):
			attach_enemy(attached_enemies[0])
		else:
			for enemy: Node2D in enemies_container.get_children():
				if enemy not in attached_enemies:
					attach_enemy(enemy)
					break
		time_since_last_connect = 0
	time_since_last_connect += delta


func attach_enemy(enemy: Node2D) -> void:
	wire_attacher.attach_enemy(enemy)
	attached_enemies.append(enemy)


func on_enemies_killed(_enemies: Array[Enemy]) -> void:
	attached_enemies = []
