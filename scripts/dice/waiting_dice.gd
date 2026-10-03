extends Sprite2D

@export var bob_height: float = 4.0
@export var bob_speed: float = 9.0
@export var pause_speed: float = 0.8
@export var talk_amount: float = 0.6

var bob_time: float = 0.0
var base_y: float = 0.0

@onready var mumble: AudioStreamPlayer = $MumbleSound


func _ready() -> void:
	base_y = position.y
	visibility_changed.connect(_on_visibility_changed)
	mumble.play()


func _process(delta: float) -> void:
	bob_time += delta

	var talking: bool = sin(bob_time * pause_speed * TAU) > -talk_amount
	if talking:
		position.y = base_y - absf(sin(bob_time * bob_speed)) * bob_height
	else:
		position.y = move_toward(position.y, base_y, bob_height * bob_speed * delta)


func _on_visibility_changed() -> void:
	if not visible:
		mumble.stop()
