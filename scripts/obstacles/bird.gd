extends MovingObstacle
class_name Bird

@export var flap_frames: Array[Texture2D] = []
@export var flap_interval: float = 0.2

@export_group("Flap Bob")
@export var bob_height: float = 30.0
@export var bob_speed: float = 3.5

var bob_time: float = 0.0
var flap_time: float = 0.0


func _ready() -> void:
	super()
	bob_time = randf() * TAU
	flap_time = randf() * flap_interval * flap_frames.size()


func _process(delta: float) -> void:
	if flap_frames.is_empty():
		return

	flap_time += delta
	sprite.texture = flap_frames[int(flap_time / flap_interval) % flap_frames.size()]


func get_bob(delta: float) -> float:
	bob_time += delta * bob_speed
	return sin(bob_time) * bob_height
