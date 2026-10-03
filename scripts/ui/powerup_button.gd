extends ArtButton
class_name PowerupButton

signal purchased

@export var id: String = ""
@export var prices: Array[int] = []
@export var max_count: int = 1
@export var price_label: Label
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var coming_soon: bool = false
@export var cant_afford_tint: Color = Color(0.5, 0.5, 0.5)
@export var bought_tint: Color = Color(1.0, 1.0, 1.0, 0.4)

@export_group("Bulbs")
@export var bulbs: Array[TextureRect] = []
@export var bulb_on: Texture2D
@export var bulb_off: Texture2D


func _ready() -> void:
	super()
	pressed.connect(_on_pressed)


func refresh() -> void:
	var count: int = GameState.powerup_count(id)
	disabled = is_full()
	update_tint(is_hovered())

	if coming_soon:
		price_label.text = "Soon"
	elif disabled:
		price_label.text = "Max"
	else:
		price_label.text = str(current_cost())

	for i in bulbs.size():
		bulbs[i].texture = bulb_on if i < count else bulb_off


func is_full() -> bool:
	return GameState.powerup_count(id) >= max_count


func current_cost() -> int:
	if prices.is_empty():
		return 0
	return prices[mini(GameState.powerup_count(id), prices.size() - 1)]


func can_buy() -> bool:
	return not coming_soon and not is_full() and GameState.can_afford(current_cost())


func update_tint(hovered: bool) -> void:
	if disabled:
		self_modulate = bought_tint
	elif hovered and not can_buy():
		self_modulate = cant_afford_tint
	else:
		self_modulate = Color.WHITE


func _on_mouse_entered() -> void:
	super()
	update_tint(true)


func _on_mouse_exited() -> void:
	super()
	update_tint(false)


func _on_pressed() -> void:
	if not can_buy():
		return

	GameState.buy_powerup(id, current_cost(), max_count)
	refresh()
	if disabled:
		set_outline(false)
	purchased.emit()
