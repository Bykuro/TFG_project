extends CanvasLayer


@onready var health_bar = $MarginContainer/Rows/BottomRow/HealthBar

var player: Player

func set_player (player_temp: Player):
	player = player_temp
	set_new_health_value(player.health_stat.health)
	
	player.player_health_change.connect(set_new_health_value)
	
	
func set_new_health_value(new_health):
	health_bar.value = new_health
