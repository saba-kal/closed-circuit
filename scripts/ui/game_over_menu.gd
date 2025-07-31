extends Control


func _enter_tree() -> void:
	visible = false


func _ready() -> void:
	SignalBus.game_over.connect(on_game_over)


func on_game_over() -> void:
	visible = true
