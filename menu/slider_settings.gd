extends Control

@onready var var_name_lbl = $HBoxContainer/Var_Name_lbl as Label
@onready var var_num_lbl = $HBoxContainer/Var_Num_lbl as Label
@onready var h_slider = $HBoxContainer/HSlider as HSlider

@export_enum ("Health multiplier","Enemies to kill","Max enemy Quantity","Enemy multiplier","Max enemies per wave") var bus_name : String

func _ready():
	h_slider.value_changed.connect(on_value_changed)
	set_name_label_text()
	set_max_and_min_values()
	
func set_name_label_text():
	var_name_lbl.text = str(bus_name)
	
func set_variable_num_label_text():
	var_num_lbl.text = str(h_slider.value)

func set_max_and_min_values():
	match bus_name:
		"Health multiplier":
			h_slider.min_value = 1
			h_slider.max_value = 2
			h_slider.step = 0.1
			h_slider.value = ModifiablePlayerValues.HEALTH_THRESHOLD_COEFICIENT
			print(h_slider.value)
		"Enemies to kill":
			h_slider.min_value = 10
			h_slider.max_value = 100
			h_slider.value = ModifiablePlayerValues.ENEMIES_KILLED_THRESHOLD
		"Max enemy Quantity":
			h_slider.min_value = 8
			h_slider.max_value = 100
			h_slider.value = ModifiablePlayerValues.MAX_ENEMY_THRESHOLD
		"Enemy multiplier":
			h_slider.min_value = 0.5
			h_slider.max_value = 2
			h_slider.step = 0.1
			h_slider.value = ModifiablePlayerValues.ENEMY_MULTIPLIER
		"Max enemies per wave":
			h_slider.min_value = 2
			h_slider.max_value = 12
			h_slider.value = ModifiablePlayerValues.MAX_ENEMIES_PER_WAVE

func on_value_changed(value: float):
	match bus_name:
		"Health multiplier":
			ModifiablePlayerValues.HEALTH_THRESHOLD_COEFICIENT = value
		"Enemies to kill":
			ModifiablePlayerValues.ENEMIES_KILLED_THRESHOLD = int(value)
		"Max enemy Quantity":
			ModifiablePlayerValues.MAX_ENEMY_THRESHOLD = int(value)
		"Enemy multiplier":
			ModifiablePlayerValues.ENEMY_MULTIPLIER = value
		"Max enemies per wave":
			ModifiablePlayerValues.MAX_ENEMIES_PER_WAVE = int(value)
		
	
	
	set_variable_num_label_text()
	pass
