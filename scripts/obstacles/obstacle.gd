extends StaticBody2D
class_name Obstacle

@export var obstacle_bounciness: float = 0.5
@export var has_top_bounciness: bool = false
@export var top_bounciness: float = 1.0
@export var launches_up: bool = false
@export var min_launch_speed: float = 0.0
@export var redirect: bool = false
@export_range(0.0, 90.0) var launch_angle: float = 45.0

@onready var sprite: Sprite2D = $Sprite
@onready var bonk_sound: AudioStreamPlayer2D = get_node_or_null("BonkSound")
@onready var side_sound: AudioStreamPlayer2D = get_node_or_null("SideSound")


func is_top_hit(normal: Vector2) -> bool:
	return normal.y < -0.7


func get_bounciness(normal: Vector2) -> float:
	return top_bounciness if has_top_bounciness and is_top_hit(normal) else obstacle_bounciness


func on_hit(normal: Vector2) -> void:
	var sound: AudioStreamPlayer2D = bonk_sound
	if side_sound and not is_top_hit(normal):
		sound = side_sound
	if sound:
		sound.play()
