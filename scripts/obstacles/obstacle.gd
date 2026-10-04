extends StaticBody2D
class_name Obstacle

@export var obstacle_bounciness: float = 0.5
@export var has_top_bounciness: bool = false
@export var top_bounciness: float = 1.0
@export var launches_up: bool = false
@export var min_launch_speed: float = 0.0
@export var redirect: bool = false
@export_range(0.0, 90.0) var launch_angle: float = 45.0

@onready var bonk_sound: AudioStreamPlayer2D = get_node_or_null("BonkSound")


func get_bounciness(normal: Vector2) -> float:
	var hit_top: bool = normal.y < -0.7
	return top_bounciness if has_top_bounciness and hit_top else obstacle_bounciness


func on_hit() -> void:
	if bonk_sound:
		bonk_sound.play()
