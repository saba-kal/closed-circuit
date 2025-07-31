extends Node

@onready var button_click_stream = $ButtonClickStream

func play_button_click() -> void:
	button_click_stream.play()
