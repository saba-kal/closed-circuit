class_name NavAgent extends NavigationAgent2D

var character_body: CharacterBody2D


func _ready() -> void:
	character_body = get_parent()
	velocity_computed.connect(on_velocity_computed)


func _physics_process(delta: float) -> void:
	if is_navigation_finished():
		return
	var next_path_position: Vector2 = get_next_path_position()
	var current_agent_position: Vector2 = character_body.global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * max_speed
	if avoidance_enabled:
		set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)


func set_movement_target(movement_target: Vector2):
	set_target_position(movement_target)


func on_velocity_computed(safe_velocity: Vector2) -> void:
	character_body.velocity = safe_velocity
	character_body.move_and_slide()
