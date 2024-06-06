extends CanvasLayer


@onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSector/HealthBar
@onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSector/CurrentAmmo
@onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSector/MaxAmmo
@onready var medkits = $MarginContainer/Rows/TopRow/MedkitSector
@onready var debug_hud = $MarginContainer/Rows/TopRow/DebugSector
var player: Player

func set_player (player_temp: Player):
	player = player_temp
	set_new_health_value(player.health_stat.health)
	
	GlobalSignals.player_health_change.connect(set_new_health_value)
	GlobalSignals.update_ammo.connect(set_new_max_ammo_value)
	GlobalSignals.medkit_action.connect(set_new_medkit_quantity)
	GlobalSignals.send_config_values.connect(update_debug_info)
	
func _unhandled_input(event):	#Check debug key
	if event.is_action_pressed("debug"):	#Show / Hide debug
		pass

func update_debug_info(new_config):	#update debug information
	
	pass

func set_new_health_value(new_health):
	health_bar.value = new_health
	
func set_new_current_ammo_value():
	current_ammo.text = str(player.weapon.mag_ammo)

func set_new_max_ammo_value():
	current_ammo.text = str(player.weapon.mag_ammo)
	max_ammo.text = str(player.weapon.max_ammo)
	
func set_new_medkit_quantity(actual_meds):
	for i in medkits.get_children():
		i.visible = false
	
	for i in actual_meds:
		medkits.get_child(i).visible = true
			
			
	
