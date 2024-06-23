extends Control

class_name DifficultySelector

@onready var easy_button = $MarginContainer/HBoxContainer/VBoxContainer/EasyButton
@onready var normal_button = $MarginContainer/HBoxContainer/VBoxContainer/NormalButton
@onready var hard_button = $MarginContainer/HBoxContainer/VBoxContainer/HardButton
@onready var adaptative_button = $MarginContainer/HBoxContainer/VBoxContainer/AdaptativeButton
@onready var start_level = preload("res://scenes/main.tscn") as PackedScene

func _on_easy_button_pressed():
	ModifiablePlayerValues.difficulty_chosen = ModifiablePlayerValues.Difficulty.EASY
	start_game()
func _on_normal_button_pressed():
	ModifiablePlayerValues.difficulty_chosen = ModifiablePlayerValues.Difficulty.NORMAL
	start_game()
func _on_hard_button_pressed():
	ModifiablePlayerValues.difficulty_chosen = ModifiablePlayerValues.Difficulty.HARD
	start_game()
func _on_adaptative_button_pressed():
	ModifiablePlayerValues.difficulty_chosen = ModifiablePlayerValues.Difficulty.DIRECTOR
	start_game()


func start_game():
	get_tree().change_scene_to_packed(start_level)
