extends Area2D
class_name Chips

@export var value: int = 10
@export var tier_values: Array[int] = [5, 10, 20, 50]
@export var tier_colors: Array[Color] = [Color("c8742e"), Color("d8dde6"), Color("ffcc1a"), Color("ff3ea5")]
@export var tier_textures: Array[Texture2D] = []

@export_group("Jackpot")
@export var jackpot_value: int = 100
@export var jackpot_color: Color = Color("00f0ff")
@export var jackpot_texture: Texture2D
@export var jackpot_scale: float = 1.4

@export_group("Hover")
@export var hover_height: float = 8.0
@export var hover_speed: float = 1.2

var base_y: float = 0.0
var hover_time: float = 0.0


func _ready() -> void:
	base_y = position.y
	hover_time = randf() * TAU


func _process(delta: float) -> void:
	hover_time += delta * hover_speed * TAU
	position.y = base_y + sin(hover_time) * hover_height


func set_tier(tier: int) -> void:
	tier = mini(tier, tier_values.size() - 1)
	value = tier_values[tier]

	if tier < tier_textures.size() and tier_textures[tier] != null:
		show_texture(tier_textures[tier])
	else:
		$ColorRect.color = tier_colors[tier]


func set_jackpot() -> void:
	value = jackpot_value
	scale = Vector2(jackpot_scale, jackpot_scale)

	if jackpot_texture != null:
		show_texture(jackpot_texture)
	else:
		$ColorRect.color = jackpot_color


func show_texture(texture: Texture2D) -> void:
	$Sprite.texture = texture
	$ColorRect.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body is Dice:
		body.collect(value)
		queue_free()
