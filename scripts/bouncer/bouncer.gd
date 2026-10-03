extends Node2D
class_name Bouncer

const DEFAULT_TEXTURE: Texture2D = preload("res://assets/sprites/mr_throw_default.png")
const BEFORE_TEXTURE: Texture2D = preload("res://assets/sprites/mr_throw_before.png")
const AFTER_TEXTURE: Texture2D = preload("res://assets/sprites/mr_throw_after.png")

@export var arm_raise: float = 60.0

@onready var body: Sprite2D = $Body
@onready var arm: Sprite2D = $Arm
@onready var hand: Marker2D = $Arm/Hand


func idle() -> void:
	arm.visible = false
	body.texture = DEFAULT_TEXTURE


func ready_up() -> void:
	arm.visible = true
	body.texture = BEFORE_TEXTURE


func aim(angle: float) -> void:
	arm.rotation = angle + deg_to_rad(arm_raise)


func throw() -> void:
	arm.visible = false
	body.texture = AFTER_TEXTURE
