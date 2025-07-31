extends Node2D

@onready var normal_sprite = $NormalSprite
@onready var angry_sprite = $AngrySprite


func _ready() -> void:
	normal_sprite.visible = true
	angry_sprite.visible = false
	var enemy: Enemy = get_parent()
	enemy.state_changed.connect(on_enemy_state_changed)


func on_enemy_state_changed(new_state: Enemy.State) -> void:
	if new_state == Enemy.State.WANDER:
		normal_sprite.visible = true
		angry_sprite.visible = false
	elif new_state == Enemy.State.ATTACK:
		normal_sprite.visible = false
		angry_sprite.visible = true
