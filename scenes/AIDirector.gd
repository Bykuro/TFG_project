extends Node2D

enum AIPhase {
	START,
	BUILDUP,
	PEAK,
	RELAX
}

var base_list: Array
var timer = Timer.new()
var timer_check = Timer.new()
var bases_captured_player = 0
var bases_captured_enemy = 0
var current_player_health = 0
var items_used = 0
var time_per_capture_player = 0
var time_per_capture_enemy = 0
var number_of_enemies = 0
var enemies_killed = 0
var max_enemies = 4
var enemy_per_wave = 0
var respawn_timer = 3.0
var item_respawn_timer = 10.0
var current_ai_phase : AIPhase = AIPhase.RELAX
var time_passed = false
var behavior_distribution_attacker = 1.0
var behavior_distribution_defender = 0.0
var behavior_distribution_seeker = 0.0
var precision_value = 1
var carried_items = 0
func initialize(capturable_bases_init: Array):
	add_child(timer)
	timer.wait_time = 45.0
	timer.start()
	add_child(timer_check)
	timer_check.wait_time = 6.0
	timer_check.start()
	base_list = capturable_bases_init



func _process(_delta):
	if timer.time_left <= 1:
		time_passed = true
		
	if timer_check.time_left <= 1:
		get_bases_captured()
		adjust_enemy_spawn_rate()
		adjust_behavior_priority()
		adjust_capture_priority()
		adjust_enemy_precision()
		adjust_item_spawn()
		timer_check.start()
	
	if time_passed:			#minimum time per phase has passed
		match current_ai_phase:	 	 #look what phase we are in & check conditions
			AIPhase.START:	#Player has majority of bases
				if bases_captured_player > 4:
					current_ai_phase = AIPhase.BUILDUP
					timer.wait_time = 60.0
					time_passed = false
					timer.start()
				pass
				
			AIPhase.BUILDUP:	#Time passes
				current_ai_phase = AIPhase.PEAK
				time_passed = false
				timer.start()
				pass
				
			AIPhase.PEAK:	#Time passes
				current_ai_phase = AIPhase.RELAX
				time_passed = false
				timer.wait_time = 30.0
				timer.start()
				pass
				
			AIPhase.RELAX:	#Player gets majority of bases
				if bases_captured_player < 4:
					current_ai_phase = AIPhase.BUILDUP
					time_passed = false
					timer.wait_time = 60.0
					timer.start()
				pass
				
			_:
				pass
		
	pass



func adjust_enemy_spawn_rate():
	match current_ai_phase:
		AIPhase.BUILDUP:		#Increase enemy count, more rapid enemy spawning
			if number_of_enemies < 4 and respawn_timer > 1:
				respawn_timer -= 0.1
			if number_of_enemies >= max_enemies:
				max_enemies += 1
			if bases_captured_enemy <= 3:
				max_enemies += 1
				respawn_timer -= 0.05
			
			pass
		AIPhase.PEAK:	#wave spawning
			enemy_per_wave = max_enemies / 3
			if enemy_per_wave > 5:
				enemy_per_wave = 5
			
			if enemy_per_wave < 3:
				max_enemies += 2
			
			pass
		AIPhase.RELAX:	#reduce enemy count, no more waves
			if  number_of_enemies > 4 and max_enemies > 4:
				max_enemies -= 1
			if respawn_timer < 1.5:
				respawn_timer += 0.1
			pass
		_:
			pass
	#send signal with max_enemies & respawn_timer
	pass
	
func adjust_enemy_spawn_sector():
	pass
	
func adjust_capture_priority():
	var list_of_bases = range(base_list.size()) 
	list_of_bases = range(base_list.size() - 1,  -1, -1)
	for i in list_of_bases:
		var base = base_list[i]
		print(base.capture_priority)
		if base.team.team == Team.TeamName.PLAYER:
			if base.capture_priority > 1:
				base.capture_priority -= 1
			if base.time_captured > 15:
				base.capture_size += 1
				
		if base.team.team == Team.TeamName.ENEMY:
			if base.time_captured > 10:
				if base.capture_size > 1:
					base.capture_size -= 1
			if base.capture_priority < 3:
				base.capture_priority += 1
				
	pass
	
func adjust_enemy_precision():
	if current_player_health >= 80 and precision_value > 0:
			precision_value -= 0.05
	elif current_player_health >= 60 and precision_value > 0:
		precision_value -= 0.025
	elif current_player_health >= 40 and precision_value < 1:
		precision_value += 0.025
	elif current_player_health >= 20 and precision_value < 1:
		precision_value += 0.05
	pass
	
func adjust_behavior_priority(): #Distribute between attackers, seekers & defenders
	match current_ai_phase:
		AIPhase.BUILDUP:
			var list_of_bases = range(base_list.size()) 
			list_of_bases = range(base_list.size() - 1,  -1, -1)
			var long_captured_enemy_bases = 0
			for i in list_of_bases:
				var base = base_list[i]
				if base.team.team == Team.TeamName.ENEMY and base.time_captured > 15:
					long_captured_enemy_bases += 1
			
			if long_captured_enemy_bases > 3 and behavior_distribution_defender < 1:	# If base majority is enemy, prioritize defense
				behavior_distribution_defender += behavior_distribution_attacker/4
				behavior_distribution_seeker += behavior_distribution_attacker/8
				behavior_distribution_attacker -= behavior_distribution_attacker/4 + behavior_distribution_attacker/8
			elif long_captured_enemy_bases < 3 and behavior_distribution_attacker < 1:	# If base majority is ally, prioritize offense
				behavior_distribution_attacker += behavior_distribution_defender/4
				behavior_distribution_seeker += behavior_distribution_defender/8
				behavior_distribution_defender -= behavior_distribution_defender/4 + behavior_distribution_defender/8
			
			if behavior_distribution_seeker > 0.25:		#there shouldn't be more than 25% of enemies seeking
				behavior_distribution_attacker += behavior_distribution_seeker/8
				behavior_distribution_defender += behavior_distribution_seeker/8
				behavior_distribution_seeker -= behavior_distribution_seeker/4
			pass
		AIPhase.PEAK:
			pass
		AIPhase.RELAX:
			var list_of_bases = range(base_list.size()) 
			list_of_bases = range(base_list.size() - 1,  -1, -1)
			var long_captured_player_bases = 0
			for i in list_of_bases:
				var base = base_list[i]
				if base.team.team == Team.TeamName.PLAYER and base.time_captured > 15:
					long_captured_player_bases += 1
			
			if long_captured_player_bases < 3:
				behavior_distribution_defender += behavior_distribution_attacker/8
				behavior_distribution_attacker -= behavior_distribution_attacker/8
			if behavior_distribution_seeker > 0:
				behavior_distribution_attacker += behavior_distribution_seeker / 2
				behavior_distribution_defender += behavior_distribution_seeker / 2
				behavior_distribution_seeker = 0
			pass
		_:
			pass
	pass
	
func adjust_item_spawn():
	match current_ai_phase:
		AIPhase.BUILDUP:	# modify respawn timer upon current health and carried items
			if current_player_health < 40 and item_respawn_timer > 5 and carried_items < 3:
				item_respawn_timer -= 0.5
			elif current_player_health > 80 and item_respawn_timer < 20:
				item_respawn_timer += 1
			pass
		AIPhase.PEAK:		#check if player already has max items carrying, if not, reduce timer
			if carried_items < 3 and item_respawn_timer > 3 and current_player_health < 50:
				item_respawn_timer -= 0.5
			pass
		AIPhase.RELAX:
			if item_respawn_timer > 15:
				item_respawn_timer -= 1
			elif item_respawn_timer < 15:
				item_respawn_timer += 1
			pass
		_:
			pass
	pass
	
func get_data_from_player(player_health_temp, items_used_temp, carried_items_temp):
	current_player_health = player_health_temp
	items_used = items_used_temp
	carried_items = carried_items_temp
	pass

func get_bases_captured():
	var list_of_bases = range(base_list.size()) 
	list_of_bases = range(base_list.size() - 1,  -1, -1)
	bases_captured_enemy = 0
	bases_captured_player = 0
	for i in list_of_bases:
		var base = base_list[i]
		if base.team.team == Team.TeamName.ENEMY:
			bases_captured_enemy += 1
		if base.team.team == Team.TeamName.PLAYER:
			bases_captured_player += 1
	pass

func add_enemy_death_count():
	enemies_killed += 1
	pass
	
func save_status():
	pass
	
