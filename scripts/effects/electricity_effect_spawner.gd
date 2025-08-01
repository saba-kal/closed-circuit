extends Node2D


@export var particle_effect: PackedScene
@export var death_effect: PackedScene

@onready var zap_sound: AudioStreamPlayer2D = $ZapSound
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound


func _ready() -> void:
	SignalBus.enemies_stunned.connect(on_enemies_stunned)
	SignalBus.enemy_killed.connect(on_enemy_killed)


func on_enemies_stunned(enemies: Array[Enemy]) -> void:
	var effects: Array[Node2D]
	for i in range(len(enemies)):

		var enemy1 = enemies[i]
		var enemy2 = enemies[(i + 1) % len(enemies)]
		var effect: GPUParticles2D = particle_effect.instantiate()
		add_child(effect)
		effect.global_position = (enemy1.global_position + enemy2.global_position) / 2
		effects.append(effect)

		# Rotate the effect to be parallel with the wire connecting the two enemies.
		var a: float = enemy2.global_position.y - enemy1.global_position.y
		var b: float = enemy2.global_position.x - enemy1.global_position.x
		var angle: float = atan(a / b)
		effect.rotation = angle

		# Set effect length to match distance between the two enemies.
		var emission_box: Vector3 = effect.process_material.emission_box_extents
		emission_box.x = enemy2.global_position.distance_to(enemy1.global_position)
	
	zap_sound.play()
	await get_tree().create_timer(0.5).timeout
	explosion_sound.play()
	await get_tree().create_timer(0.25).timeout
	for effect: Node2D in effects:
		effect.queue_free()


func on_enemy_killed(enemy: Enemy) -> void:
	var effect: Node2D = death_effect.instantiate()
	add_child(effect)
	effect.global_position = enemy.global_position
