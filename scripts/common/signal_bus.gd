extends Node

signal enemy_killed(enemy: Enemy)
signal game_over()
signal wire_attached(node: Node2D, attached_nodes: Array[Node2D])
signal wire_reset()
signal enemies_stunned(enemies: Array[Enemy])
signal player_damaged()
