extends Node2D
class_name Game

const PIXELS_PER_METER: float = 50.0

@export var meter_speed: float = 120.0
@export var power_to_speed: float = 15.0
@export var ground_y: float = 620.0
@export var sky_gradient: Gradient
@export var sky_top_height: float = 3000.0

var start_x: float
var distance: float = 0.0
var power: float = 0.0
var meter_direction: int = 1
var thrown: bool = false
var run_chips: int = 0

@onready var meter: ProgressBar = $HUD/ProgressBar
@onready var distance_label: Label = $HUD/DistanceLabel
@onready var chips_label: Label = $HUD/ChipsLabel
@onready var launch_point: Marker2D = $LaunchPoint
@onready var dice: Dice = $Dice
@onready var bouncer: Bouncer = $Bouncer
@onready var sky: ColorRect = $Sky/SkyColor


func _ready() -> void:
	dice.global_position = launch_point.global_position
	start_x = dice.global_position.x
	dice.visible = false

	dice.run_ended.connect(_on_dice_run_ended)
	dice.chip_collected.connect(_on_dice_chip_collected)


func _process(delta: float) -> void:
	update_hud()
	if thrown:
		return

	update_meter(delta)
	var angle: float = get_aim_angle()
	launch_point.rotation = angle
	bouncer.aim(angle)

	if Input.is_action_just_pressed("throw"):
		throw(angle)


func update_hud() -> void:
	distance = (dice.global_position.x - start_x) / PIXELS_PER_METER
	distance_label.text = "%d m" % distance

	var height: float = ground_y - dice.global_position.y
	sky.color = sky_gradient.sample(clampf(height / sky_top_height, 0.0, 1.0))


func update_meter(delta: float) -> void:
	power += meter_speed * meter_direction * delta
	if power >= 100:
		meter_direction = -1
	if power <= 0:
		meter_direction = 1

	power = clampf(power, 0.0, 100.0)
	meter.value = power


func get_aim_angle() -> float:
	var to_mouse: Vector2 = get_global_mouse_position() - launch_point.global_position
	return clampf(to_mouse.angle(), deg_to_rad(-85), deg_to_rad(0))


func throw(angle: float) -> void:
	thrown = true
	print("Power: ", power, " Angle: ", rad_to_deg(angle))

	dice.global_position = bouncer.hand.global_position
	start_x = dice.global_position.x
	dice.visible = true

	bouncer.throw()
	dice.launch(Vector2.from_angle(angle) * power * power_to_speed)


func _on_dice_run_ended() -> void:
	print("Run ended! Distance: ", int(distance), " m")


func _on_dice_chip_collected(amount: int) -> void:
	run_chips += amount
	chips_label.text = "Chips: %d" % run_chips
