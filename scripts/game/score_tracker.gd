class_name ScoreTracker extends Node

@export var score_label: Label

var score: int = 0


func _ready() -> void:
	score_label.text = str(score)
	SignalBus.enemy_killed.connect(on_enemy_killed)
	SignalBus.game_over.connect(on_game_over)


func on_enemy_killed(_enemy: Enemy) -> void:
	score += 1
	score_label.text = str(score)
	if score > PlayerData.highest_score:
		PlayerData.highest_score = score


func on_game_over() -> void:
	score_label.visible = false
