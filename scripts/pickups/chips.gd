extends Area2D
class_name Chips

@export var tier_values: Array[int] = [5, 10, 20, 50]
@export var tier_starts: Array[float] = [0.0, 100.0, 200.0, 500.0]
@export var tier_textures: Array[Texture2D] = []

@export_group("Jackpot")
@export var jackpot_value: int = 100
@export var jackpot_texture: Texture2D
@export var jackpot_scale: float = 1.2

@export_group("Hover")
@export var hover_height: float = 10.0
@export var hover_speed: float = 0.6

var value: int = 0
var is_jackpot: bool = false
var base_y: float = 0.0
var hover_time: float = 0.0


func _ready() -> void:
	base_y = position.y
	hover_time = randf() * TAU


func _physics_process(delta: float) -> void:
	hover_time += delta * hover_speed * TAU
	position.y = base_y + sin(hover_time) * hover_height


func set_distance(meters: float) -> void:
	var unlocked: int = 1
	for i in tier_starts.size():
		if meters >= tier_starts[i]:
			unlocked = i + 1

	var tier: int = randi() % unlocked
	value = tier_values[tier]
	$Sprite.texture = tier_textures[tier]


func set_jackpot() -> void:
	value = jackpot_value
	is_jackpot = true
	scale = Vector2(jackpot_scale, jackpot_scale)
	$Sprite.texture = jackpot_texture


func get_half_size() -> float:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	return shape.size.x / 2.0 * scale.x


func _on_body_entered(body: Node2D) -> void:
	if body is Dice:
		body.collect(value, is_jackpot)
		queue_free()
