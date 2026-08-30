extends Node3D


signal opened_game_from_menu
signal start_game
#node referances

@export var env: Environment
@export var main_menu_on : bool

#@onready var test_bench = $"Test bench"
@onready var canvas = $CanvasLayer
@onready var world_env = $WorldEnvironment
@onready var level1 = $"Level 1"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("opened_game_from_menu")
	level1.visible = false
	world_env.environment = null
	
	if not main_menu_on:
		begin_game()
	
	

func begin_game():
	emit_signal("start_game")
	level1.visible = true
	canvas.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	begin_game()



func _on_anti_aliasing_button_toggled(toggled_on: bool) -> void:
	
	#Tuff boiler plate code for toggiling anti aliasing
	if toggled_on:
		
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		get_viewport().msaa_3d = Viewport.MSAA_2X
	else:
		
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED


func _on_tuff_graphics_button_toggled(toggled_on: bool) -> void:
	
	if toggled_on:
		
		world_env.environment = env
		
	else:
		
		world_env.environment = null
