extends Node


func _ready() -> void:
	var config_file = "./config.json"
	var config_text = FileAccess.get_file_as_string(config_file)
	var config_dict = JSON.parse_string(config_text)
	SilentWolf.configure({
		"api_key": config_dict["silent_wolf_api_key"],
		"game_id": config_dict["silent_wolf_game_id"],
		"log_level": config_dict["silent_wolf_log_level"]
	})
