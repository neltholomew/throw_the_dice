extends Node2D

const PALM_SCENE: PackedScene = preload("res://scenes/obstacles/palm_tree.tscn")
const CHIPS_SCENE: PackedScene = preload("res://scenes/pickups/chips.tscn")

@export var dice: Dice
@export var ground_y: float = 620.0
@export var spawn_ahead: float = 1500.0
@export var despawn_behind: float = 1500.0

@export_group("Palms")
@export var min_gap: float = 1000.0
@export var max_gap: float = 2000.0
@export var palm_lookahead: float = 600.0
@export var min_scale: float = 1.3
@export var max_scale: float = 1.8

@export_group("Chips")
@export var chip_min_gap: float = 600.0
@export var chip_max_gap: float = 1200.0
@export var chip_spread: float = 360.0
@export var chip_min_height: float = 250.0
@export var chip_radius: float = 60.0
@export var chip_palm_gap: float = 10.0
@export var meters_per_tier: float = 100.0
@export var jackpot_chance: float = 0.05

var next_palm_x: float = 1500.0
var next_chip_x: float = 1500.0
var palms: Array[Node2D] = []


func _physics_process(_delta: float) -> void:
	var spawn_limit: float = dice.global_position.x + spawn_ahead

	while next_palm_x < spawn_limit + palm_lookahead:
		spawn_palm(next_palm_x)
		next_palm_x += randf_range(min_gap, max_gap)

	while next_chip_x < spawn_limit:
		spawn_chip(next_chip_x)
		next_chip_x += randf_range(chip_min_gap, chip_max_gap)

	despawn_old()


func spawn_palm(x: float) -> void:
	var palm: Node2D = PALM_SCENE.instantiate()
	var size: float = randf_range(min_scale, max_scale)
	palm.scale = Vector2(size, size)
	palm.position = Vector2(x, ground_y)

	add_child(palm)
	palms.append(palm)


func spawn_chip(x: float) -> void:
	var y: float = dice.global_position.y + randf_range(-chip_spread, chip_spread)
	y = minf(y, ground_y - chip_min_height)

	var chip: Chips = CHIPS_SCENE.instantiate()
	chip.position = Vector2(x, y)

	if randf() < jackpot_chance:
		chip.set_jackpot()
	else:
		var meters: float = x / Game.PIXELS_PER_METER
		chip.set_tier(int(meters / meters_per_tier))

	var clearance: float = chip_radius * chip.scale.x + chip.hover_height + chip_palm_gap
	if overlaps_palm(chip.position, clearance):
		chip.free()
		return

	add_child(chip)


func overlaps_palm(point: Vector2, clearance: float) -> bool:
	for palm: Node2D in palms:
		var sprite: Sprite2D = palm.get_node("Sprite")
		var palm_rect: Rect2 = palm.transform * sprite.transform * sprite.get_rect()
		if palm_rect.grow(clearance).has_point(point):
			return true

	return false


func despawn_old() -> void:
	var despawn_x: float = dice.global_position.x - despawn_behind

	for child: Node2D in get_children():
		if child.position.x < despawn_x:
			palms.erase(child)
			child.queue_free()
