extends Node2D

@onready var label: Label = $Label


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		label.text = "Rolled: %d" % randi_range(1, 6)
