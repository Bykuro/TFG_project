extends CanvasLayer


@onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSector/HealthBar
@onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSector/CurrentAmmo
@onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSector/MaxAmmo
var player: Player

func set_player (player_temp: Player):
	player = player_temp
	set_new_health_value(player.health_stat.health)
	
	player.player_health_change.connect(set_new_health_value)
	GlobalSignals.update_ammo.connect(set_new_max_ammo_value)
	#player.
	
func set_new_health_value(new_health):
	health_bar.value = new_health
	
func set_new_current_ammo_value():
	current_ammo.text = str(player.weapon.mag_ammo)

func set_new_max_ammo_value():
	current_ammo.text = str(player.weapon.mag_ammo)
	max_ammo.text = str(player.weapon.max_ammo)
