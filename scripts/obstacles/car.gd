extends MovingObstacle
class_name Car

@export var color_textures: Array[Texture2D] = []

@export_group("Engine Shake")
@export var shake_height: float = 1.5
@export var shake_tilt: float = 0.6
@export var shake_speed: float = 35.0

var shake_time: float = 0.0
var sprite_y: float = 0.0

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	super()
	if not color_textures.is_empty():
		sprite.texture = color_textures.pick_random()
	sprite_y = sprite.position.y
	shake_time = randf() * TAU


func _process(delta: float) -> void:
	shake_time += delta * shake_speed
	sprite.position.y = sprite_y + sin(shake_time) * shake_height
	sprite.rotation = deg_to_rad(sin(shake_time * 0.7) * shake_tilt)
