class_name ScoreTracker extends Node

@export var score_label: Label

var score: int = 0


func _ready() -> void:
	score_label.text = str(score)
	SignalBus.enemies_killed.connect(on_enemies_killed)
	SignalBus.game_over.connect(on_game_over)


func on_enemies_killed(enemies: Array[Enemy]) -> void:
	for enemy in enemies:
		score += len(enemies) * enemy.score_value
	score_label.text = str(score)
	if score > PlayerData.highest_score:
		PlayerData.highest_score = score


func on_game_over() -> void:
	score_label.visible = false
