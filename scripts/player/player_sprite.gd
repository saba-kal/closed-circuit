extends AnimatedSprite2D

var player: Player


func _ready() -> void:
	player = get_parent()


func _process(delta: float) -> void:
	
	if player.velocity.x < 0 and !flip_h:
		flip_h = true
	if player.velocity.x > 0 and flip_h:
		flip_h = false
	
	if player.velocity.length_squared() > 0.01:
		play("run")
	else:
		play("idle")
