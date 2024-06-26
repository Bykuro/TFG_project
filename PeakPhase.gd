extends Node

var config = preload("res://ConfigData.gd").new()



func load_data(new_config):		#Gets current values to work with
	config = new_config
	
func update(new_config):
	config.bases_captured_player = new_config.bases_captured_player
	config.bases_captured_enemy = new_config.bases_captured_enemy
	adjust_enemy_spawn_rate()
	adjust_item_spawn()
	return config
	
func check_state():	#If player too low on health and has no items to heal or there are too many enemies, switch phase
	if (config.current_player_health < 20 and config.carried_items <= 0) or config.number_of_enemies >= ModifiablePlayerValues.MAX_ENEMY_THRESHOLD:
		return true

func get_next_state():
	return 3
	
func adjust_enemy_spawn_rate():
	config.enemy_per_wave = config.max_enemies / 3
	if config.enemy_per_wave > ModifiablePlayerValues.MAX_ENEMIES_PER_WAVE:
		config.enemy_per_wave = ModifiablePlayerValues.MAX_ENEMIES_PER_WAVE
			
	if config.enemy_per_wave < ModifiablePlayerValues.ENEMY_MULTIPLIER:
		config.max_enemies += 2 * ModifiablePlayerValues.ENEMY_MULTIPLIER
	pass
	
func adjust_item_spawn():
	if config.carried_items < 3 and config.item_respawn_timer > 5 and config.current_player_health < 50:
		config.item_respawn_timer -= 0.5
	pass
