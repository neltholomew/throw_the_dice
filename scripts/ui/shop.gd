extends CanvasLayer
class_name Shop

@export var tooltip_gap: float = 10.0

@onready var bank_label: Label = %BankLabel
@onready var throw_button: ArtButton = %ThrowButton
@onready var menu_button: ArtButton = %MenuButton
@onready var music: AudioStreamPlayer = $Music
@onready var buy_sound: AudioStreamPlayer = $BuySound
@onready var tooltip: Control = $Tooltip
@onready var tooltip_title: Label = %TooltipTitle
@onready var tooltip_text: Label = %TooltipText

var powerup_buttons: Array[PowerupButton] = []


func _ready() -> void:
	visible = false
	throw_button.pressed.connect(GameState.start_run)
	menu_button.pressed.connect(GameState.go_to_title)

	for button: Node in find_children("*", "TextureButton", true, false):
		if button is PowerupButton:
			powerup_buttons.append(button)
			button.purchased.connect(_on_powerup_purchased)
			button.mouse_entered.connect(show_tooltip.bind(button))
			button.mouse_exited.connect(tooltip.hide)


func open() -> void:
	update_labels()
	for button: PowerupButton in powerup_buttons:
		button.refresh()
	visible = true
	get_tree().paused = true
	music.play()
	throw_button.grab_focus()


func update_labels() -> void:
	bank_label.text = "Chips: %d" % GameState.total_chips


func _on_powerup_purchased() -> void:
	update_labels()
	buy_sound.play()


func show_tooltip(button: PowerupButton) -> void:
	tooltip_title.text = button.display_name
	tooltip_text.text = button.description

	var item: Rect2 = button.get_screen_item_rect()
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var x: float = item.end.x + tooltip_gap
	if item.get_center().x < screen.x / 2.0:
		x = item.position.x - tooltip.size.x - tooltip_gap

	x = clampf(x, tooltip_gap, screen.x - tooltip.size.x - tooltip_gap)
	tooltip.position = Vector2(x, item.get_center().y - tooltip.size.y / 2.0)
	tooltip.show()
