extends Obstacle
class_name MovingObstacle

@export var min_speed: float = 150.0
@export var max_speed: float = 350.0
@export var min_height: float = 0.0
@export var max_height: float = 0.0
@export var height_bias: float = 1.0

var drive_speed: float = 0.0
var driving: bool = false
var base_y: float = 0.0

@onready var passing_sound: AudioStreamPlayer2D = get_node_or_null("PassingSound")
@onready var on_screen: VisibleOnScreenNotifier2D = get_node_or_null("OnScreen")


func _ready() -> void:
	drive_speed = randf_range(min_speed, max_speed)
	base_y = position.y

	if passing_sound and on_screen:
		on_screen.screen_entered.connect(passing_sound.play)
		on_screen.screen_exited.connect(passing_sound.stop)


func _physics_process(delta: float) -> void:
	var x: float = position.x
	if driving:
		x -= drive_speed * delta

	position = Vector2(x, base_y + get_bob(delta))


func get_bob(_delta: float) -> float:
	return 0.0
