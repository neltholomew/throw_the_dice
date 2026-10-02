extends Node2D

const PIXELS_PER_METER: float = 50.0
var start_x: float
var distance: float = 0.0 
var power: float = 0.0
@export var meter_speed: float = 120.0
@export var power_to_speed: float = 15.0
var direction: int = 1
var thrown: bool = false
@onready var meter: ProgressBar = $HUD/ProgressBar
@onready var launch_point: Marker2D = $LaunchPoint
@onready var dice: Dice = $Dice
@onready var distance_label: Label = $HUD/DistanceLabel

func _ready() -> void:
	dice.global_position = launch_point.global_position
	start_x = dice.global_position.x
	dice.run_ended.connect(_on_dice_run_ended)
	
func _process(delta: float) -> void:
	distance = (dice.global_position.x - start_x) / PIXELS_PER_METER 
	distance_label.text = "%d m" % distance
	if thrown:
		return
	power += meter_speed * direction * delta
	if power >= 100:
		direction = -1
	if power <= 0:
		direction = 1
	power = clampf(power, 0.0, 100.0)
	meter.value = power
	var to_mouse: Vector2 = get_global_mouse_position() - launch_point.global_position
	var angle: float = to_mouse.angle()
	angle = clampf(angle, deg_to_rad(-85), deg_to_rad(0))
	launch_point.rotation = angle
	if Input.is_action_just_pressed("throw"):
		thrown = true
		print("Power: ",power, " Angle: ", rad_to_deg(angle))
		dice.launch(Vector2.from_angle(angle) * power * power_to_speed)
	
	
func _on_dice_run_ended() -> void:
		print("Run ended! Distance: ", int(distance), " m")
	
	
