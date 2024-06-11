extends Control

class_name MainMenu

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/OptionsButton
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton
@onready var start_level = preload("res://scenes/main.tscn") as PackedScene
@onready var options_menu = $Options_Menu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer

func _ready():
	handle_connecting_signals()
	
func on_start_pressed():
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed():
	get_tree().quit()
	
func on_option_pressed():
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
func on_exit_options_menu():
	margin_container.visible = true
	options_menu.visible = false
	
func handle_connecting_signals():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	options_button.button_down.connect(on_option_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
