extends Node

@export var score_label: Label

var score: int = 0


func _ready() -> void:
	score_label.text = str(score)
	SignalBus.enemy_killed.connect(on_enemy_killed)


func on_enemy_killed(_enemy: Enemy):
	score += 1
	score_label.text = str(score)
