extends Node

var known_scenes: Dictionary[String, PackedScene] = {
	"main_menu": preload("res://scenes/main_menu.tscn"),
	"main_level": preload("res://scenes/main_level.tscn")
}


func change_scene(scene_name: String) -> void:
	get_tree().change_scene_to_packed(known_scenes[scene_name])
