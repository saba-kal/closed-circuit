extends Control

@export var resume_button: Button
@export var main_menu_button: Button

var can_pause: bool = true


func _ready() -> void:
	set_paused(false)
	resume_button.pressed.connect(on_resume_button)
	main_menu_button.pressed.connect(on_main_menu_button_pressed)
	SignalBus.game_over.connect(on_game_over)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_paused(!get_tree().paused)


func set_paused(is_paused: bool) -> void:
	if is_paused && !can_pause:
		return
	visible = is_paused
	get_tree().paused = is_paused


func on_resume_button() -> void:
	set_paused(false)


func on_main_menu_button_pressed() -> void:
	set_paused(false)
	SceneHandler.change_scene("main_menu")


func on_game_over() -> void:
	can_pause = false
	set_paused(false)
