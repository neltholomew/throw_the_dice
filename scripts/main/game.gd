extends Node2D
class_name Game

enum Phase { INTRO, AIMING, FLYING, OVER }

const PIXELS_PER_METER: float = 50.0
const GROUND_Y: float = 620.0

@export var meter_speed: float = 120.0
@export var power_to_speed: float = 15.0
@export var steroids_bonus: float = 5.0
@export var game_over_delay: float = 1.0
@export var distance_display_scale: float = 0.25

var phase: Phase = Phase.INTRO
var start_x: float
var shown_distance: float = 0.0
var power: float = 0.0
var meter_time: float = 0.0
var run_chips: int = 0

@onready var distance_label: Label = $HUD/DistanceBox/DistanceLabel
@onready var chips_label: Label = $HUD/ChipsBox/ChipsLabel
@onready var throw_prompt: Label = $HUD/ThrowPrompt
@onready var waiting_dice: Sprite2D = $WaitingDice
@onready var launch_point: Marker2D = $LaunchPoint
@onready var aim_arrow: TextureProgressBar = $LaunchPoint/AimArrow
@onready var dice: Dice = $Dice
@onready var bouncer: Bouncer = $Bouncer
@onready var game_over: GameOver = $GameOver
@onready var shop: Shop = $Shop
@onready var music: AudioStreamPlayer = $Music
@onready var surprised_sound: AudioStreamPlayer = $SurprisedSound


func _ready() -> void:
	dice.global_position = launch_point.global_position
	start_x = dice.global_position.x
	dice.visible = false

	dice.run_ended.connect(_on_dice_run_ended)
	dice.chip_collected.connect(_on_dice_chip_collected)
	game_over.shop_pressed.connect(_on_shop_pressed)

	bouncer.idle()
	launch_point.visible = false

	power_to_speed += steroids_bonus * GameState.take_powerup("steroids")
	dice.fart_charges = GameState.take_powerup("beans")


func _process(delta: float) -> void:
	update_hud()

	if phase == Phase.AIMING:
		aim(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("throw"):
		return

	match phase:
		Phase.INTRO:
			start_aiming()
		Phase.AIMING:
			throw(get_aim_angle())


func start_aiming() -> void:
	phase = Phase.AIMING
	surprised_sound.play()
	throw_prompt.visible = false
	waiting_dice.visible = false
	launch_point.visible = true
	bouncer.ready_up()


func aim(delta: float) -> void:
	update_meter(delta)
	var angle: float = get_aim_angle()
	launch_point.rotation = angle
	bouncer.aim(angle)


func update_hud() -> void:
	shown_distance = (dice.global_position.x - start_x) / PIXELS_PER_METER * distance_display_scale
	distance_label.text = "%d m" % shown_distance


func update_meter(delta: float) -> void:
	meter_time += delta
	power = pingpong(meter_time * meter_speed, 100.0)
	aim_arrow.value = power


func get_aim_angle() -> float:
	var to_mouse: Vector2 = get_global_mouse_position() - launch_point.global_position
	return clampf(to_mouse.angle(), deg_to_rad(-85), deg_to_rad(0))


func throw(angle: float) -> void:
	phase = Phase.FLYING
	launch_point.visible = false

	dice.global_position = bouncer.hand.global_position
	start_x = dice.global_position.x
	dice.visible = true

	bouncer.throw()
	dice.launch(Vector2.from_angle(angle) * power * power_to_speed)


func _on_dice_run_ended() -> void:
	phase = Phase.OVER
	GameState.finish_run(shown_distance, run_chips)
	get_tree().create_timer(game_over_delay, false).timeout.connect(game_over.show_results)


func _on_dice_chip_collected(amount: int) -> void:
	run_chips += amount
	chips_label.text = "Chips: %d" % run_chips


func _on_shop_pressed() -> void:
	music.stream_paused = true
	shop.open()
