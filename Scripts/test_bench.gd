extends Node3D



var first_scene = "test_bench"

signal start_game


var delay = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#just here for testing purpases to let me either
	#start the game from the menu, or skip the menu and
	#get straight into gameplay.
	
	#Basicly just waits 10 frames to see if we have recived signal from main menu
	#theres probaly better ways to do it but too late
	
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
