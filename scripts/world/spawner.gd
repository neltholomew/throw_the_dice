extends Node2D

const PALM_SCENE: PackedScene = preload("res://scenes/obstacles/palm_tree.tscn")
const CAR_SCENE: PackedScene = preload("res://scenes/obstacles/car.tscn")
const BUILDING_SCENE: PackedScene = preload("res://scenes/obstacles/building.tscn")
const SKYSCRAPER_SCENE: PackedScene = preload("res://scenes/obstacles/skyscraper.tscn")
const BIRD_SCENE: PackedScene = preload("res://scenes/obstacles/bird.tscn")
const PLANE_SCENE: PackedScene = preload("res://scenes/obstacles/plane.tscn")
const CHIPS_SCENE: PackedScene = preload("res://scenes/pickups/chips.tscn")

@export var dice: Dice
@export var spawn_ahead: float = 1500.0
@export var despawn_behind: float = 1500.0

@export_group("Obstacles")
@export var min_gap: float = 1000.0
@export var max_gap: float = 2000.0
@export var obstacle_lookahead: float = 600.0

@export_group("Palms")
@export var palm_chance: float = 0.525
@export var min_scale: float = 1.3
@export var max_scale: float = 1.8

@export_group("Cars")
@export var car_chance: float = 0.175

@export_group("Buildings")
@export var building_start: float = 250.0
@export var building_full_at: float = 750.0
@export var building_chance: float = 0.3
@export var skyscraper_start: float = 750.0
@export var skyscraper_full_at: float = 1500.0
@export var skyscraper_chance: float = 0.2

@export_group("Air")
@export var air_min_gap: float = 750.0
@export var air_max_gap: float = 1500.0
@export var bird_start: float = 100.0
@export var bird_full_at: float = 300.0
@export var bird_chance: float = 0.7
@export var plane_start: float = 100.0
@export var plane_full_at: float = 300.0
@export var plane_chance: float = 0.4

@export_group("Chips")
@export var chip_min_gap: float = 600.0
@export var chip_max_gap: float = 1200.0
@export var chip_spread: float = 360.0
@export var chip_min_height: float = 250.0
@export var chip_obstacle_gap: float = 10.0
@export var jackpot_chance_start: float = 0.02
@export var jackpot_chance_max: float = 0.1
@export var jackpot_max_at: float = 1500.0

var next_obstacle_x: float = 1500.0
var next_chip_x: float = 1500.0
var next_air_x: float = 1500.0
var blockers: Array[Node2D] = []
var last_was_building: bool = false


func _ready() -> void:
	dice.launched.connect(_on_dice_launched)


func _physics_process(_delta: float) -> void:
	var spawn_limit: float = dice.global_position.x + spawn_ahead

	while next_obstacle_x < spawn_limit + obstacle_lookahead:
		spawn_obstacle(next_obstacle_x)
		next_obstacle_x += randf_range(min_gap, max_gap)

	var zoom: float = view_zoom()
	while next_chip_x < spawn_limit:
		spawn_chip(next_chip_x, zoom)
		next_chip_x += randf_range(chip_min_gap, chip_max_gap) * zoom

	while next_air_x < spawn_limit:
		spawn_air(next_air_x)
		next_air_x += randf_range(air_min_gap, air_max_gap)

	despawn_old()


func spawn_obstacle(x: float) -> void:
	var meters: float = to_meters(x)
	var tower_chance: float = skyscraper_chance * ramp(meters, skyscraper_start, skyscraper_full_at)
	var house_chance: float = building_chance * ramp(meters, building_start, building_full_at)
	if last_was_building:
		tower_chance = 0.0
		house_chance = 0.0

	var pick: int = pick_weighted([tower_chance, house_chance, palm_chance, car_chance])
	match pick:
		0:
			spawn_blocker(SKYSCRAPER_SCENE.instantiate(), x)
		1:
			spawn_blocker(BUILDING_SCENE.instantiate(), x)
		2:
			spawn_palm(x)
		3:
			spawn_mover(CAR_SCENE.instantiate(), x)

	last_was_building = pick == 0 or pick == 1


func spawn_air(x: float) -> void:
	var meters: float = to_meters(x)
	var bird_weight: float = bird_chance * ramp(meters, bird_start, bird_full_at)
	var plane_weight: float = plane_chance * ramp(meters, plane_start, plane_full_at)

	match pick_weighted([bird_weight, plane_weight]):
		0:
			spawn_mover(BIRD_SCENE.instantiate(), x)
		1:
			spawn_mover(PLANE_SCENE.instantiate(), x)


func pick_weighted(weights: Array[float]) -> int:
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	if total <= 0.0:
		return -1

	var roll: float = randf() * total
	for i in weights.size():
		if roll < weights[i]:
			return i
		roll -= weights[i]
	return weights.size() - 1


func ramp(meters: float, start: float, full_at: float) -> float:
	return clampf((meters - start) / (full_at - start), 0.0, 1.0)


func to_meters(x: float) -> float:
	return x / Game.PIXELS_PER_METER


func spawn_mover(mover: MovingObstacle, x: float) -> void:
	var height: float = lerpf(mover.min_height, mover.max_height, pow(randf(), mover.height_bias))
	mover.position = Vector2(x, Game.GROUND_Y - height)
	mover.driving = dice.is_launched()
	add_child(mover)


func spawn_palm(x: float) -> void:
	var palm: Node2D = PALM_SCENE.instantiate()
	var size: float = randf_range(min_scale, max_scale)
	palm.scale = Vector2(size, size)
	spawn_blocker(palm, x)


func spawn_blocker(blocker: Node2D, x: float) -> void:
	blocker.position = Vector2(x, Game.GROUND_Y)
	add_child(blocker)
	blockers.append(blocker)


func view_zoom() -> float:
	var camera: Camera2D = get_viewport().get_camera_2d()
	return camera.zoom.x if camera else 1.0


func predict_dice_y(x: float) -> float:
	if dice.velocity.x < 1.0:
		return dice.global_position.y

	var t: float = (x - dice.global_position.x) / dice.velocity.x
	return dice.global_position.y + dice.velocity.y * t + 0.5 * dice.gravity * t * t


func spawn_chip(x: float, zoom: float) -> void:
	var spread: float = chip_spread / zoom
	var y: float = predict_dice_y(x) + randf_range(-spread, spread)
	y = minf(y, Game.GROUND_Y - chip_min_height)

	var chip: Chips = CHIPS_SCENE.instantiate()
	chip.position = Vector2(x, y)

	var meters: float = to_meters(x)
	var jackpot_chance: float = lerpf(jackpot_chance_start, jackpot_chance_max, ramp(meters, 0.0, jackpot_max_at))

	if randf() < jackpot_chance:
		chip.set_jackpot()
	else:
		chip.set_distance(meters)

	var clearance: float = chip.get_half_size() + chip.hover_height + chip_obstacle_gap
	if overlaps_blocker(chip.position, clearance):
		chip.free()
		return

	add_child(chip)


func overlaps_blocker(point: Vector2, clearance: float) -> bool:
	for blocker: Node2D in blockers:
		if get_blocker_rect(blocker).grow(clearance).has_point(point):
			return true

	return false


func get_blocker_rect(blocker: Node2D) -> Rect2:
	var sprite: Sprite2D = blocker.get_node("Sprite")
	if sprite.texture:
		return blocker.transform * sprite.transform * sprite.get_rect()

	var shape: Control = blocker.get_node("Shape")
	return blocker.transform * shape.get_rect()


func despawn_old() -> void:
	var despawn_x: float = dice.global_position.x - despawn_behind

	for child: Node2D in get_children():
		if child.position.x < despawn_x:
			blockers.erase(child)
			child.queue_free()


func _on_dice_launched() -> void:
	for child: Node in get_children():
		if child is MovingObstacle:
			child.driving = true
