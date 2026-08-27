extends Node3D


signal opened_game_from_menu
signal start_game
#node referances

@onready var test_bench = $"Test bench"
@onready var canvas = $CanvasLayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("opened_game_from_menu")
	test_bench.visible = false
	
	

func begin_game():
	emit_signal("start_game")
	test_bench.visible = true
	canvas.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	begin_game()


func _on_check_button_toggled(toggled_on: bool) -> void:
	
	#Tuff boiler plate code for toggiling anti aliasing
	if toggled_on:
		
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		get_viewport().msaa_3d = Viewport.MSAA_2X
	else:
		
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
