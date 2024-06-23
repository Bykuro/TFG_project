extends Node



var PLAYER_BASE_THRESHOLD = 4

#Percentual value of enemy distribution
var behavior_distribution_attacker = 1.0
var behavior_distribution_defender = 0.0
var behavior_distribution_seeker = 0.0

#Values for bases captured per team
var bases_captured_player = 0
var bases_captured_enemy = 0
var long_captured_enemy_bases = 0

#Values related to items
var item_respawn_timer = 10.0
var items_used = 0
var carried_items = 2

#Values related to enemy difficulty
var precision_value = 1
var enemies_killed = 0
var max_enemies = 4
var enemy_per_wave = 1
var respawn_timer = 10.0
var number_of_enemies = 4

#Values related to player 
var current_player_health = 0



func update(new_config):
	
	behavior_distribution_attacker = new_config.behavior_distribution_attacker
	behavior_distribution_defender = new_config.behavior_distribution_defender
	behavior_distribution_seeker = new_config.behavior_distribution_seeker
	
	bases_captured_player = new_config.bases_captured_player
	bases_captured_enemy = new_config.bases_captured_enemy
	
	item_respawn_timer = new_config.item_respawn_timer
	items_used = new_config.items_used
	carried_items = new_config.carried_items
	
	precision_value = new_config.precision_value
	enemies_killed = new_config.enemies_killed
	max_enemies = new_config.max_enemies
	enemy_per_wave = new_config.enemy_per_wave
	respawn_timer = new_config.respawn_timer
	number_of_enemies = new_config.number_of_enemies
	
	current_player_health = new_config.current_player_health
 	
 	

func start_difficulty(difficulty: ModifiablePlayerValues.Difficulty):
	
	match difficulty:
		ModifiablePlayerValues.Difficulty.EASY:
			behavior_distribution_attacker = 0.5
			behavior_distribution_defender = 0.5
			behavior_distribution_seeker = 0.0
			item_respawn_timer = 5.0
			precision_value = 3
			max_enemies = 16
			enemy_per_wave = 1
			respawn_timer = 5.0	
			pass
		ModifiablePlayerValues.Difficulty.NORMAL:
			behavior_distribution_attacker = 0.4
			behavior_distribution_defender = 0.4
			behavior_distribution_seeker = 0.2
			item_respawn_timer = 6.0
			precision_value = 1.5
			max_enemies = 25
			enemy_per_wave = 2
			respawn_timer = 4.0
			pass
		ModifiablePlayerValues.Difficulty.HARD:
			behavior_distribution_attacker = 0.5
			behavior_distribution_defender = 0.25
			behavior_distribution_seeker = 0.25
			item_respawn_timer = 7.0
			precision_value = 0.5
			max_enemies = 40
			enemy_per_wave = 4
			respawn_timer = 3.0
			pass
	



