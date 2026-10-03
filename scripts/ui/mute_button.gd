extends CanvasLayer

@export var sound_on_icon: Texture2D
@export var sound_off_icon: Texture2D

@onready var button: TextureButton = $Button
@onready var icon: TextureRect = $Button/Icon


func _ready() -> void:
	button.button_pressed = AudioServer.is_bus_mute(0)
	button.toggled.connect(_on_toggled)
	update_icon()


func update_icon() -> void:
	icon.texture = sound_off_icon if button.button_pressed else sound_on_icon


func _on_toggled(muted: bool) -> void:
	AudioServer.set_bus_mute(0, muted)
	update_icon()
