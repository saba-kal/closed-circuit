extends Node

@onready var button: Button = get_parent()

func _ready() -> void:
	button.pressed.connect(on_button_pressed)


func on_button_pressed() -> void:
	AudioManager.play_button_click()
