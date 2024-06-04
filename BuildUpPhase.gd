extends Node

var config



func load_data(new_config):		#Gets current values to work with
	config = new_config
	

func update(new_config):
	config.bases_captured_player = new_config.bases_captured_player
	config.bases_captured_enemy = new_config.bases_captured_enemy
	config.enemies_killed = new_config.enemies_killed
	config.number_of_enemies = new_config.number_of_enemies
	config.base_list = new_config.base_list
	adjust_enemy_spawn_rate()
	adjust_behavior_priority()
	adjust_item_spawn()
	return config
	
func check_state():
	if config.enemies_killed > config.ENEMIES_KILLED_THRESHOLD:
		return true 

func get_next_state():
	return 2

func adjust_enemy_spawn_rate():
	if config.number_of_enemies < 4 and config.respawn_timer > 5:
		config.respawn_timer -= 0.1
	if config.number_of_enemies >= config.max_enemies:
		config.max_enemies += 1
	if config.bases_captured_enemy <= 3:
		config.max_enemies += 1
		config.respawn_timer -= 0.1

	pass

func adjust_behavior_priority(): #Distribute between attackers, seekers & defenders
	if config.long_captured_enemy_bases > 3 and config.behavior_distribution_defender < 1:	# If base majority is enemy, prioritize defense
		config.behavior_distribution_defender += config.behavior_distribution_attacker/4
		config.behavior_distribution_seeker += config.behavior_distribution_attacker/8
		config.behavior_distribution_attacker -= config.behavior_distribution_attacker/4 + config.behavior_distribution_attacker/8
	elif config.long_captured_enemy_bases < 3 and config.behavior_distribution_attacker < 1:	# If base majority is ally, prioritize offense
		config.behavior_distribution_attacker += config.behavior_distribution_defender/4
		config.behavior_distribution_seeker += config.behavior_distribution_defender/8
		config.behavior_distribution_defender -= config.behavior_distribution_defender/4 + config.behavior_distribution_defender/8
	
	if config.behavior_distribution_seeker > 0.25:		#there shouldn't be more than 25% of enemies seeking
		config.behavior_distribution_attacker += config.behavior_distribution_seeker/8
		config.behavior_distribution_defender += config.behavior_distribution_seeker/8
		config.behavior_distribution_seeker -= config.behavior_distribution_seeker/4
	pass
	
func adjust_item_spawn():
	if config.current_player_health < 40 and config.item_respawn_timer > 5 and config.carried_items < 3:
		config.item_respawn_timer -= 0.5
	elif config.current_player_health > 80 and config.item_respawn_timer < 15:
		config.item_respawn_timer += 1
	pass
