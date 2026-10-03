extends CanvasLayer
class_name PauseMenu

@export var music_volume_paused: float = -10.0

var was_paused: bool = false

@onready var resume_button: ArtButton = %ResumeButton
@onready var title_button: ArtButton = %TitleButton
@onready var quit_button: ArtButton = %QuitButton


func _ready() -> void:
	visible = false

	resume_button.pressed.connect(close)
	title_button.pressed.connect(GameState.go_to_title)
	quit_button.pressed.connect(GameState.quit)
	quit_button.visible = not OS.has_feature("web")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	was_paused = get_tree().paused
	get_tree().paused = true
	GameState.set_music_volume(music_volume_paused)
	visible = true
	resume_button.grab_focus()


func close() -> void:
	visible = false
	get_tree().paused = was_paused
	GameState.set_music_volume(0.0)
