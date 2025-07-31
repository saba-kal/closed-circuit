extends Control

@export var player: Player


func _ready() -> void:
	for i in range(0, player.max_health):
		get_child(i).visible = true
	player.health_changed.connect(on_health_changed)


func on_health_changed(new_health: int) -> void:
	for i in range(0, new_health):
		get_child(i).visible = true
	for i in range(new_health, player.max_health):
		get_child(i).visible = false
