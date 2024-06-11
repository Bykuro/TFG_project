extends Node2D

enum AIPhase {
	START,
	BUILDUP,
	PEAK,
	RELAX
}

var base_list: Array
var timer_check = Timer.new()
var current_ai_phase : AIPhase = AIPhase.START

var current_phase
var config = preload("res://ConfigData.gd").new()

func initialize(capturable_bases_init: Array):
	change_phase(AIPhase.START)
	add_child(timer_check)
	timer_check.wait_time = 6.0
	timer_check.start()
	base_list = capturable_bases_init
	GlobalSignals.player_health_change.connect(update_health)
	GlobalSignals.medkit_action.connect(update_items)
	GlobalSignals.enemy_spawned.connect(update_enemies)
	GlobalSignals.emit_signal("send_config_values", config)
	GlobalSignals.sendCurrentPhase.emit(current_ai_phase)

func update_health(new_health):
	config.current_player_health = new_health
	pass

func update_items(new_inventory):
	config.carried_items = new_inventory

func update_enemies(new_enemy_quantity):
	config.number_of_enemies = new_enemy_quantity
	
func _process(_delta):

	if timer_check.time_left <= 1:		#Every 5 seconds update information about game
		current_phase_update()
		timer_check.start()
	# ADD DEBUG OPTION TO VISUALIZE INFORMATION



func current_phase_update():
	get_bases_captured()
	adjust_capture_priority()
	adjust_enemy_precision()
	config = current_phase.update(config)
	GlobalSignals.emit_signal("send_config_values", config)
	if current_phase.check_state():
		change_phase(current_phase.get_next_state())

func change_phase(new_phase: AIPhase):
	if current_phase != null:
		current_phase.queue_free()
	match new_phase:
		AIPhase.START:
			current_phase = preload("res://StartPhase.gd").new()
		AIPhase.BUILDUP:
			current_phase = preload("res://BuildUpPhase.gd").new()
		AIPhase.PEAK:
			current_phase = preload("res://PeakPhase.gd").new()
		AIPhase.RELAX:
			current_phase = preload("res://RelaxPhase.gd").new()
	GlobalSignals.sendCurrentPhase.emit(new_phase)
	current_phase.load_data(config)




func adjust_capture_priority():
	var list_of_bases = range(base_list.size()) 
	list_of_bases = range(base_list.size() - 1,  -1, -1)
	for i in list_of_bases:
		var base = base_list[i]
		print(base.capture_priority)
		if base.team.team == Team.TeamName.PLAYER:
			if base.capture_priority > 1:
				base.capture_priority -= 1
			if base.time_captured.wait_time - base.time_captured.time_left > 15:
				base.capture_size += 1
				
		if base.team.team == Team.TeamName.ENEMY:
			if base.time_captured.wait_time - base.time_captured.time_left > 10:
				if base.capture_size > 1:
					base.capture_size -= 1
			if base.capture_priority < 3:
				base.capture_priority += 1
		if base.team.team == Team.TeamName.NEUTRAL:
			if base.capture_size > 1:
				base.capture_size -= 1
			if base.capture_priority > 1:
				base.capture_priority -= 1
				
	pass
	
func adjust_enemy_precision():
	if config.current_player_health >= 80 and config.precision_value > 0:
		config.precision_value -= 0.1
	elif config.current_player_health >= 60 and config.precision_value > 0:
		config.precision_value -= 0.75
	elif config.current_player_health >= 40 and config.precision_value < 5 and config.carried_items >= 2:
		config.precision_value -= 0.05
	elif config.current_player_health >= 40 and config.precision_value < 5 and config.carried_items < 2:
		config.precision_value += 0.05
	elif config.current_player_health >= 20 and config.precision_value < 5:
		config.precision_value += 0.075
	pass
	
func get_data_from_player(player_health_temp, items_used_temp, carried_items_temp):
	config.current_player_health = player_health_temp
	config.items_used = items_used_temp
	config.carried_items = carried_items_temp
	pass

func get_bases_captured():
	var list_of_bases = range(base_list.size()) 
	list_of_bases = range(base_list.size() - 1,  -1, -1)
	config.bases_captured_enemy = 0
	config.bases_captured_player = 0
	for i in list_of_bases:
		var base = base_list[i]
		if base.team.team == Team.TeamName.ENEMY:
			config.bases_captured_enemy += 1
			if base.time_captured.wait_time - base.time_captured.time_left > 10:
				config.long_captured_enemy_bases += 1
		if base.team.team == Team.TeamName.PLAYER:
			config.bases_captured_player += 1
			
	
	pass

func add_enemy_death_count():
	config.enemies_killed += 1
	pass
	
func save_status():
	pass
	
