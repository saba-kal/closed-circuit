extends Button

@export_enum("main_level", "main_menu") var scene_name: String = "main_level"


func _ready() -> void:
	pressed.connect(on_pressed)


func on_pressed() -> void:
	SceneHandler.change_scene(scene_name)
