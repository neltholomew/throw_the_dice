extends Obstacle
class_name Palm

@export_group("Sway")
@export var sway_angle: float = 3.0
@export var sway_speed: float = 12.0
@export var sway_decay: float = 3.0

var sway_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	set_process(false)


func on_hit() -> void:
	super()
	sway_time = 0.0
	set_process(true)


func _process(delta: float) -> void:
	sway_time += delta
	var strength: float = exp(-sway_decay * sway_time)
	sprite.rotation = deg_to_rad(sway_angle) * strength * sin(sway_speed * sway_time)

	if strength < 0.01:
		sprite.rotation = 0.0
		set_process(false)
