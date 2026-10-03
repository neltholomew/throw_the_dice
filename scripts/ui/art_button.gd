extends TextureButton
class_name ArtButton

@export var press_scale: float = 0.95
@export var press_time: float = 0.08

var item_rect: Rect2
var image_size: Vector2
var scale_tween: Tween


func _ready() -> void:
	material = material.duplicate()

	var image: Image = texture_normal.get_image()
	var mask: BitMap = BitMap.new()
	mask.create_from_image_alpha(image)
	texture_click_mask = mask
	item_rect = Rect2(image.get_used_rect())
	image_size = Vector2(image.get_size())

	resized.connect(update_pivot)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(press_to.bind(press_scale))
	button_up.connect(press_to.bind(1.0))
	update_pivot()


func update_pivot() -> void:
	pivot_offset = item_rect.get_center() * size / image_size


func get_screen_item_rect() -> Rect2:
	var factor: Vector2 = size / image_size
	return Rect2(global_position + item_rect.position * factor, item_rect.size * factor)


func set_outline(on: bool) -> void:
	material.set_shader_parameter("outline_on", on)


func press_to(target: float) -> void:
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * target, press_time)


func _on_mouse_entered() -> void:
	if not disabled:
		set_outline(true)


func _on_mouse_exited() -> void:
	if not disabled:
		set_outline(false)
