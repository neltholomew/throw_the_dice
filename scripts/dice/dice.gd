extends CharacterBody2D
class_name Dice

signal launched
signal hit_obstacle
signal chip_collected(amount: int)
signal run_ended

const FLY_TEXTURE: Texture2D = preload("res://assets/sprites/dice_flying.png")
const BOUNCE_TEXTURE: Texture2D = preload("res://assets/sprites/dice_bounce.png")
const SLIDE_TEXTURE: Texture2D = preload("res://assets/sprites/dice_slide.png")
const STOP_TEXTURE: Texture2D = preload("res://assets/sprites/dice_stop.png")

@export var dice_size: float = 40.0
@export var gravity: float = 980.0
@export var bounciness: float = 0.7
@export var speed_to_slide: float = 150.0
@export var friction: float = 200.0
@export var ground_grip: float = 0.9
@export var stop_below_speed: float = 10.0
@export var stop_after: float = 0.5
@export var boost_falloff: float = 2000.0
@export var ghost_when_sliding: bool = true

var still_time: float = 0.0
var flying: bool = false

@onready var sprite: Sprite2D = $Sprite


func launch(launch_velocity: Vector2) -> void:
	velocity = launch_velocity
	flying = true
	launched.emit()


func collect(amount: int) -> void:
	chip_collected.emit(amount)


func _physics_process(delta: float) -> void:
	if not flying:
		return

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
	if sprite.texture == BOUNCE_TEXTURE:
		sprite.rotation += velocity.x / dice_size * delta
	elif sprite.texture == FLY_TEXTURE:
		sprite.rotation = clampf(velocity.angle(), deg_to_rad(-90), deg_to_rad(90))


func bounce_off_obstacle(collision: KinematicCollision2D, obstacle: Obstacle) -> void:
	var boost: float = obstacle.bounciness
	if boost > 1.0:
		boost = 1.0 + (boost - 1.0) * boost_falloff / (boost_falloff + velocity.length())

	velocity = velocity.bounce(collision.get_normal()) * boost
	velocity.x = absf(velocity.x)
	if obstacle.launches_up:
		velocity.y = -absf(velocity.y)

	add_collision_exception_with(obstacle)
	for part: StaticBody2D in obstacle.linked:
		add_collision_exception_with(part)

	sprite.texture = BOUNCE_TEXTURE
	hit_obstacle.emit()


func slide(collision: KinematicCollision2D, delta: float) -> void:
	if ghost_when_sliding:
		set_collision_mask_value(2, false)

	velocity.y = 0
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	sprite.rotation = 0
	sprite.texture = SLIDE_TEXTURE
	move_and_collide(collision.get_remainder().slide(collision.get_normal()))


func bounce_off_ground(collision: KinematicCollision2D) -> void:
	velocity = velocity.bounce(collision.get_normal())
	velocity.y *= bounciness
	velocity.x *= ground_grip
	sprite.texture = BOUNCE_TEXTURE


func check_stopped(delta: float) -> void:
	if velocity.length() < stop_below_speed:
		still_time += delta
	else:
		still_time = 0

	if still_time >= stop_after:
		sprite.texture = STOP_TEXTURE
		flying = false
		run_ended.emit()
