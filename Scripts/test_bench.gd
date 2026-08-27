extends Node3D



var first_scene = "test_bench"

signal start_game


var delay = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	delay += 1
	
	if delay == 10:
		if first_scene == "test_bench":
			emit_signal("start_game")
	
		else:
			pass
func _on_main_menu_opened_game_from_menu() -> void:
	first_scene = "menu"


func _on_main_menu_start_game() -> void:
	emit_signal("start_game")
