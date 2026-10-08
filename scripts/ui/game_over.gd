extends CanvasLayer
class_name GameOver

signal shop_pressed

@onready var distance_label: Label = %DistanceLabel
@onready var best_label: Label = %BestLabel
@onready var chips_label: Label = %ChipsLabel
@onready var total_label: Label = %TotalLabel
@onready var throw_again_button: ArtButton = %ThrowAgainButton
@onready var shop_button: ArtButton = %ShopButton


func _ready() -> void:
	visible = false
	throw_again_button.pressed.connect(GameState.start_run)
	shop_button.pressed.connect(_on_shop_pressed)


func show_results() -> void:
	distance_label.text = "Distance: %d m" % GameState.last_distance
	chips_label.text = get_chips_text()
	total_label.text = "Bank: %d" % GameState.total_chips

	if GameState.last_distance > 0 and GameState.last_distance >= GameState.best_distance:
		best_label.text = "NEW BEST!"
	else:
		best_label.text = "Best: %d m" % GameState.best_distance

	visible = true
	throw_again_button.grab_focus()


func get_chips_text() -> String:
	if GameState.last_multiplier <= 1.0:
		return "Chips: +%d" % GameState.last_chips

	var multiplier: String = String.num(GameState.last_multiplier).trim_suffix(".0")
	return "Chips: %d × %s = +%d" % [GameState.last_raw_chips, multiplier, GameState.last_chips]


func _on_shop_pressed() -> void:
	visible = false
	shop_pressed.emit()
