extends CharacterBody2D
class_name Dice

enum State { IDLE, FLYING, BOUNCING, SLIDING, STOPPED }

signal launched
signal hit_obstacle
signal chip_collected(amount: int)
signal run_ended
signal farted

const FLY_TEXTURE: Texture2D = preload("res://assets/sprites/dice_flying.png")
const BOUNCE_TEXTURE: Texture2D = preload("res://assets/sprites/dice_bounce.png")
const SLIDE_TEXTURE: Texture2D = preload("res://assets/sprites/dice_slide.png")
const STOP_TEXTURE: Texture2D = preload("res://assets/sprites/dice_stop.png")

const STATE_TEXTURES: Dictionary = {
	State.FLYING: FLY_TEXTURE,
	State.BOUNCING: BOUNCE_TEXTURE,
	State.SLIDING: SLIDE_TEXTURE,
	State.STOPPED: STOP_TEXTURE,
}

@export_group("Flight")
@export var gravity: float = 980.0
@export var spin_slowness: float = 80.0

@export_group("Ground")
@export var bounciness: float = 0.7
@export var ground_grip: float = 0.95
@export var speed_to_slide: float = 220.0
@export var friction: float = 400.0
@export var ghost_when_sliding: bool = true

@export_group("Stopping")
@export var stop_below_speed: float = 10.0
@export var stop_after: float = 0.5

@export_group("Obstacles")
@export var boost_falloff: float = 2000.0

@export_group("Fart")
@export var fart_angle: float = 45.0
@export var fart_boost: float = 700.0

@export_group("Sound")
@export var grunt_min_speed: float = 300.0

var state: State = State.IDLE
var still_time: float = 0.0
var fart_charges: int = 0

@onready var sprite: Sprite2D = $Sprite
@onready var coin_sound: AudioStreamPlayer2D = $CoinSound
@onready var jackpot_sound: AudioStreamPlayer2D = $JackpotSound
@onready var fart_sound: AudioStreamPlayer2D = $FartSound
@onready var grunt_sound: AudioStreamPlayer2D = $GruntSound
@onready var woah_sound: AudioStreamPlayer2D = $WoahSound
@onready var slide_sound: AudioStreamPlayer2D = $SlideSound
@onready var sigh_sound: AudioStreamPlayer2D = $SighSound


func launch(launch_velocity: Vector2) -> void:
	velocity = launch_velocity
	set_state(State.FLYING)
	woah_sound.play()
	launched.emit()


func is_launched() -> bool:
	return state != State.IDLE


func collect(amount: int, jackpot: bool) -> void:
	if jackpot:
		jackpot_sound.play()
	else:
		coin_sound.play()

	chip_collected.emit(amount)


func set_state(new_state: State) -> void:
	state = new_state
	if state == State.SLIDING:
		if not slide_sound.playing:
			slide_sound.play()
	elif slide_sound.playing:
		slide_sound.stop()

	if STATE_TEXTURES.has(state):
		sprite.texture = STATE_TEXTURES[state]


func _physics_process(delta: float) -> void:
	if state == State.IDLE or state == State.STOPPED:
		return

	if can_fart() and Input.is_action_just_pressed("jump"):
		fart()

	velocity.y += gravity * delta
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	update_rotation(delta)

	if collision:
		var collider: Object = collision.get_collider()
		if collider is Obstacle:
			bounce_off_obstacle(collision, collider)
		elif collision.get_normal().y < -0.7 and velocity.y < speed_to_slide:
			slide(collision, delta)
		else:
			bounce_off_ground(collision)

	check_stopped(delta)


func update_rotation(delta: float) -> void:
	match state:
		State.BOUNCING:
			sprite.rotation += velocity.x / spin_slowness * delta
		State.FLYING:
			sprite.rotation = clampf(velocity.angle(), deg_to_rad(-90), deg_to_rad(90))


func bounce_off_obstacle(collision: KinematicCollision2D, obstacle: Obstacle) -> void:
	var boost: float = obstacle.get_bounciness(collision.get_normal())
	if boost > 1.0:
		boost = 1.0 + (boost - 1.0) * boost_falloff / (boost_falloff + velocity.length())

	velocity = velocity.bounce(collision.get_normal()) * boost
	velocity.x = absf(velocity.x)
	if obstacle.launches_up:
		velocity.y = -absf(velocity.y)
		velocity.y = minf(velocity.y, -obstacle.min_launch_speed)
	if obstacle.redirect:
		velocity = Vector2.from_angle(deg_to_rad(-obstacle.launch_angle)) * velocity.length()

	add_collision_exception_with(obstacle)

	set_state(State.BOUNCING)
	obstacle.on_hit()
	hit_obstacle.emit()


func can_fart() -> bool:
	return fart_charges > 0 and (state == State.FLYING or state == State.BOUNCING)


func fart() -> void:
	fart_charges -= 1
	velocity = Vector2.from_angle(deg_to_rad(-fart_angle)) * (velocity.length() + fart_boost)
	still_time = 0.0
	set_state(State.FLYING)
	fart_sound.play()
	farted.emit()


func slide(collision: KinematicCollision2D, delta: float) -> void:
	if ghost_when_sliding:
		set_collision_mask_value(2, false)

	velocity.y = 0
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	sprite.rotation = 0
	set_state(State.SLIDING)
	move_and_collide(collision.get_remainder().slide(collision.get_normal()))


func bounce_off_ground(collision: KinematicCollision2D) -> void:
	if velocity.y > grunt_min_speed and not grunt_sound.playing:
		grunt_sound.play()

	velocity = velocity.bounce(collision.get_normal())
	velocity.y *= bounciness
	velocity.x *= ground_grip
	set_state(State.BOUNCING)


func check_stopped(delta: float) -> void:
	if velocity.length() < stop_below_speed:
		still_time += delta
	else:
		still_time = 0

	if still_time >= stop_after:
		set_state(State.STOPPED)
		sigh_sound.play()
		run_ended.emit()
