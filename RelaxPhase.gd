extends Node

var config

func load_data(new_config):
	config = new_config
	
func update(new_config):
	config.bases_captured_player = new_config.bases_captured_player
	config.bases_captured_enemy = new_config.bases_captured_enemy
	adjust_enemy_spawn_rate()
	adjust_behavior_priority()
	adjust_item_spawn()
	return config
	pass
	
func check_state():
	if config.bases_captured_player < config.PLAYER_BASE_THRESHOLD:
		return true
	pass

func get_next_state():
	return 1
	
func adjust_enemy_spawn_rate():
	if  config.number_of_enemies > 4 and config.max_enemies > 4:
		config.max_enemies -= 1
	if config.respawn_timer < 1.5:
		config.respawn_timer += 0.1
	pass

func adjust_behavior_priority(): #Distribute between attackers, seekers & defenders
	if config.long_captured_player_bases < 3:
		config.behavior_distribution_defender += config.behavior_distribution_attacker/8
		config.behavior_distribution_attacker -= config.behavior_distribution_attacker/8
	if config.behavior_distribution_seeker > 0:
		config.behavior_distribution_attacker += config.behavior_distribution_seeker / 2
		config.behavior_distribution_defender += config.behavior_distribution_seeker / 2
		config.behavior_distribution_seeker = 0
	pass
	
func adjust_item_spawn():
	if config.item_respawn_timer > 15:
		config.item_respawn_timer -= 1
	elif config.item_respawn_timer < 15:
		config.item_respawn_timer += 1
	pass
