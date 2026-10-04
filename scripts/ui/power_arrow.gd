extends Sprite2D
class_name PowerArrow

@export var bulb_on: Texture2D
@export var bulb_off: Texture2D

@onready var body_bulbs: Array[Node] = $Body.get_children()
@onready var tip_bulbs: Array[Node] = $Tip.get_children()


# Body bulbs come in top/bottom pairs, one pair per column, from tail to tip.
# The body is full at the sweet spot, and the tip lights from it upward.
func show_power(power: float, sweet_spot: float) -> void:
	var columns: int = body_bulbs.size() / 2
	var lit_columns: int = mini(int(power / sweet_spot * columns), columns)
	for i in body_bulbs.size():
		body_bulbs[i].texture = bulb_on if i / 2 < lit_columns else bulb_off

	for bulb: Sprite2D in tip_bulbs:
		bulb.texture = bulb_on if power >= sweet_spot else bulb_off
