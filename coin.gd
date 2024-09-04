extends Sprite2D


var coins = {"Copper": 0, "Silver": 0, "Gold": 0}
@export var type: int:
	set = set_type

signal _picked_up()

func set_type(_type):
	type = _type
	texture = get_text(type)

func get_text(type):
	if type == 0:
		scale.x = .05
		scale.y = .05
		return preload("res://assets/coppercoin.png")
	if type == 1:
		scale.x = .178
		scale.y = .178
		return preload("res://assets/file.png")
	if type == 2:
		scale.x = .13
		scale.y = .13
		return preload("res://assets/coppercoin .png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEventMouseButton, shape_idx: int) -> void:
	visible = false
	emit_signal("_picked_up")
