extends MovingObstacle
class_name AirPlane

@export_group("Sign Plane")
@export var sign_chance: float = 0.05
@export var sign_texture: Texture2D
@export var sign_offset: Vector2 = Vector2.ZERO
@export var sign_on_screen_rect: Rect2


func _ready() -> void:
	super()
	if sign_texture and randf() < sign_chance:
		sprite.texture = sign_texture
		sprite.offset = sign_offset
		on_screen.rect = sign_on_screen_rect
