class_name AttackChargeEffect extends GPUParticles2D


func set_enabled(is_enabled: bool) -> void:
	emitting = is_enabled
	visible = is_enabled
