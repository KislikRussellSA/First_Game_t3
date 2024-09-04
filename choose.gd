extends Node2D

var game: PackedScene = preload("res://try2.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
var kill = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if kill:
		$Button.queue_free()
		$Button2.queue_free()
		kill = false



func _on_button_pressed() -> void:
	var g = game.instantiate()
	add_child(g)
	g.game = "s"
	kill = true

func _on_button_2_pressed() -> void:
	var g = game.instantiate()
	add_child(g)
	g.game = "e"
	kill = true
