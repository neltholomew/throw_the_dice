extends CharacterBody2D
class_name Dice
signal run_ended

@export var gravity: float = 980.0
@export var bounciness: float = 0.7
@export var min_bounce_speed: float = 150.0
@export var friction: float = 200.0
@export var stop_speed: float = 10.0
var still_time: float = 0.0
var flying: bool = false


func launch(launch_velocity:Vector2) -> void:
	velocity = launch_velocity
	flying = true


func _physics_process(delta: float) -> void:
	if not flying:
		return
	velocity.y += gravity * delta
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		if collision.get_normal().y < -0.7 and velocity.y < min_bounce_speed:
			velocity.y = 0
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		else:
			velocity = velocity.bounce(collision.get_normal()) * bounciness
	if velocity.length() < stop_speed:
		still_time += delta
	else:
		still_time = 0
	if still_time >= 0.5:
		flying = false
		run_ended.emit()
