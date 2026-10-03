extends Control

@onready var start_button: ArtButton = %StartButton
@onready var quit_button: ArtButton = %QuitButton


func _ready() -> void:
	start_button.pressed.connect(GameState.start_run)
	quit_button.pressed.connect(GameState.quit)
	quit_button.visible = not OS.has_feature("web")
	start_button.grab_focus()
