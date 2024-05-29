extends Node


# Called when the node enters the scene tree for the first time.

var config

func load_data(new_config):		#Gets current values to work with
	config = new_config

func get_data():
	return config
	
func update(new_config):
	config.bases_captured_player = new_config.bases_captured_player
	config.bases_captured_enemy = new_config.bases_captured_enemy
	print("hello")
	print(config.items_used)
	
func check_state():
	if config.bases_captured_player > config.PLAYER_BASE_THRESHOLD:
		return true
	
func get_next_state():
	return 1
