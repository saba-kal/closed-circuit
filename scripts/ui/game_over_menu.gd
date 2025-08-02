extends Control

@export var score_tracker: ScoreTracker
@export var final_score_label: Label
@export var save_score_button: Button
@export var player_name_field: LineEdit
@export var leaderboard_text: RichTextLabel

@onready var game_over_sound: AudioStreamPlayer = $GameOverSound


var player_leaderboard_position: int = 0
var max_leaderboard_entries: int = 10
var player_saved_score: bool = false


func _enter_tree() -> void:
	visible = false


func _ready() -> void:
	SignalBus.game_over.connect(on_game_over)
	SilentWolf.Scores.sw_get_scores_complete.connect(on_get_scores_complete)
	save_score_button.pressed.connect(on_save_score_button)
	player_name_field.text_changed.connect(on_player_name_text_changed)


func on_game_over() -> void:
	game_over_sound.play()
	await get_tree().create_timer(1).timeout
	visible = true
	save_score_button.disabled = len(PlayerData.player_name) <=0
	player_name_field.text = PlayerData.player_name
	final_score_label.text = "FINAL SCORE: " + str(score_tracker.score)
	leaderboard_text.text = "Loading..."
	SilentWolf.Scores.get_scores()


func on_get_scores_complete(result: Dictionary) -> void:

	var player_found: bool = false
	var table_text = "[table=2]"
	for i in range(len(result.scores)):
		var score_dict = result.scores[i]
		var color: String = "WHITE"
		if score_dict["player_name"] == PlayerData.player_name:
			color = "YELLOW"
			player_found = true
		table_text += "[cell expand=80 shrink=false][color=%s]%d. %s[/color][/cell]" % [color, i+1, score_dict["player_name"]]
		table_text += "[cell expand=20 shrink=false][right][color=%s]%d[/color][/right][/cell]" % [color, int(score_dict["score"])]
	
	if !player_found && player_saved_score:
		var score_pos_result = await SilentWolf.Scores.get_score_position(PlayerData.highest_score).sw_get_position_complete
		var player_leaderboard_position = int(score_pos_result["position"])
		table_text += "[cell expand=80 shrink=false][color=WHITE]...[/color][/cell]"
		table_text += "[cell expand=20 shrink=false][/cell]"
		table_text += "[cell expand=80 shrink=false][color=YELLOW]%d. %s[/color][/cell]" % [player_leaderboard_position, PlayerData.player_name]
		table_text += "[cell expand=20 shrink=false][right][color=YELLOW]%d[/color][/right][/cell]" % score_tracker.score

	table_text += "[/table]"
	
	leaderboard_text.text = table_text


func on_save_score_button() -> void:
	save_score_button.disabled = true
	player_name_field.editable = false
	leaderboard_text.text = "Loading..."
	PlayerData.player_name = player_name_field.text
	await SilentWolf.Scores.save_score(player_name_field.text, score_tracker.score).sw_save_score_complete
	player_saved_score = true
	SilentWolf.Scores.get_scores()


func on_player_name_text_changed(new_text: String) -> void:
	save_score_button.disabled = len(new_text) <=0
