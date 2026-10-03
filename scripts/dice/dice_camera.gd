extends Camera2D

@export var low_height: float = 300.0
@export var high_height: float = 1300.0
@export var min_zoom: float = 0.5
@export var zoom_smoothing: float = 2.0
@export var zoom_curve: float = 0.4

@onready var dice: Dice = get_parent()


func _process(delta: float) -> void:
	var height: float = Game.GROUND_Y - dice.global_position.y
	var t: float = clampf(inverse_lerp(low_height, high_height, height), 0.0, 1.0)
	t = ease(t, zoom_curve)
	var target: float = lerpf(1.0, min_zoom, t)
	var current: float = lerpf(zoom.x, target, 1.0 - exp(-zoom_smoothing * delta))
	zoom = Vector2(current, current)
