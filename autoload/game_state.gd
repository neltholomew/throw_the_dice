extends Node

const GAME_SCENE: String = "res://scenes/main/game.tscn"
const TITLE_SCENE: String = "res://scenes/main/title.tscn"
const HOVER_SOUND: AudioStream = preload("res://assets/audio/hover_over_button.wav")
const HOVER_VOLUME: float = -25.0
const PRESS_SOUND: AudioStream = preload("res://assets/audio/button_press.wav")
const PRESS_VOLUME: float = -30.0

var total_chips: int = 0
var best_distance: float = 0.0
var last_distance: float = 0.0
var last_chips: int = 0
var next_run_powerups: Dictionary = {}
var hover_player: AudioStreamPlayer
var press_player: AudioStreamPlayer


func _ready() -> void:
	hover_player = make_ui_player(HOVER_SOUND, HOVER_VOLUME)
	press_player = make_ui_player(PRESS_SOUND, PRESS_VOLUME)

	for button: Node in get_tree().root.find_children("*", "BaseButton", true, false):
		hook_button(button)
	get_tree().node_added.connect(_on_node_added)


func make_ui_player(stream: AudioStream, volume: float) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player


func finish_run(distance: float, chips: int) -> void:
	last_distance = distance
	last_chips = chips
	total_chips += chips
	best_distance = maxf(best_distance, distance)


func can_afford(cost: int) -> bool:
	return total_chips >= cost


func powerup_count(id: String) -> int:
	return next_run_powerups.get(id, 0)


func buy_powerup(id: String, cost: int, max_count: int) -> bool:
	if powerup_count(id) >= max_count or not can_afford(cost):
		return false

	total_chips -= cost
	next_run_powerups[id] = powerup_count(id) + 1
	return true


func take_powerup(id: String) -> int:
	var count: int = powerup_count(id)
	next_run_powerups.erase(id)
	return count


func start_run() -> void:
	change_scene(GAME_SCENE)


func go_to_title() -> void:
	change_scene(TITLE_SCENE)


func quit() -> void:
	get_tree().quit()


func change_scene(path: String) -> void:
	get_tree().paused = false
	set_music_volume(0.0)
	get_tree().change_scene_to_file(path)


func set_music_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		hook_button(node)


func hook_button(button: BaseButton) -> void:
	button.mouse_entered.connect(_on_button_hovered.bind(button))
	button.pressed.connect(press_player.play)


func _on_button_hovered(button: BaseButton) -> void:
	if not button.disabled:
		hover_player.play()
