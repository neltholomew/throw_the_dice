extends CharacterBody2D
class_name Dice
signal run_ended
signal launched

const BOUNCE_TEXTURE: Texture2D = preload("res://assets/sprites/dice_bounce.png")
const FLY_TEXTURE: Texture2D = preload("res://assets/sprites/dice_flying.png")
@onready var sprite: Sprite2D = $Sprite
@export var roll_radius: float = 40.0
@export var gravity: float = 980.0
@export var bounciness: float = 0.7
@export var min_bounce_speed: float = 150.0
@export var friction: float = 200.0
@export var stop_speed: float = 10.0
var still_time: float = 0.0
var flying: bool = false
var bouncing: bool = false


func launch(launch_velocity:Vector2) -> void:
	velocity = launch_velocity
	flying = true
	launched.emit()


func _physics_process(delta: float) -> void:
	if not flying:
		return
	velocity.y += gravity * delta
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if bouncing:
		sprite.rotation += velocity.x / roll_radius * delta
	elif sprite.texture == FLY_TEXTURE:
		sprite.rotation = clampf(velocity.angle(), deg_to_rad(-90), deg_to_rad(90))
	if collision:
		if collision.get_normal().y < -0.7 and velocity.y < min_bounce_speed:
			velocity.y = 0
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			bouncing = false
			sprite.rotation = 0
		else:
			velocity = velocity.bounce(collision.get_normal()) * bounciness
			sprite.texture = BOUNCE_TEXTURE
			bouncing = true
	if velocity.length() < stop_speed:
		still_time += delta
	else:
		still_time = 0
	if still_time >= 0.5:
		flying = false
		run_ended.emit()
