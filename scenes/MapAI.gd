extends Node2D

enum BaseCaptureStartOrder {
	FIRST,
	LAST
}


@export var base_capture_start_order = BaseCaptureStartOrder.FIRST
@export var team_name = Team.TeamName.NEUTRAL	
@export var unit:PackedScene = null
@export var max_units_alive = 4
var enemy_per_wave = 1
var pathfinding: Pathfinding
var target_offensive_base = null
var target_defensive_base = null
var capturable_bases: Array =[]
var respawn_points:Array =[]
var next_spawn_to_use = 0
var player_unit: CharacterBody2D = null
var defender_coeficient  = 0
var capturer_coeficient = 1
var seeker_coeficient = 0

@onready var team = $Team
@onready var unit_container = $UnitContainer
@onready var respawn_timer = $RespawnTimer

func initialize(capturable_bases_init: Array, pathfinding_init: Pathfinding, respawn_points_init: Array):
	capturable_bases = capturable_bases_init
	respawn_points = respawn_points_init
	team.team = team_name
	pathfinding = pathfinding_init
	if capturable_bases.size() == 0 or respawn_points.size() == 0 or unit == null:
		push_error("MapAI not initialized")
		return
		
	for respawn in respawn_points:
		spawn_unit(respawn.global_position)
	
	
	GlobalSignals.base_captured.connect(handle_base_captured)
	GlobalSignals.send_config_values.connect(get_new_values)
	check_for_next_capturable_bases_init()
	GlobalSignals.emit_signal("enemy_spawned",unit_container.get_children().size())

func handle_base_captured():
	check_for_next_capturable_bases()
	check_for_next_defendable_base()

func get_new_values(new_config):	#Update enemy precision; enemies per wave, max enemies, enemy behavior coeficient
	capturer_coeficient = new_config.behavior_distribution_attacker
	defender_coeficient = new_config.behavior_distribution_defender
	seeker_coeficient = new_config.behavior_distribution_seeker
	enemy_per_wave = new_config.enemy_per_wave
	max_units_alive = new_config.max_enemies
	respawn_timer.wait_time = new_config.respawn_timer
	
func check_for_next_capturable_bases_init():
	var next_base = get_next_capturable_base_init()
	if next_base != null:
		target_offensive_base = next_base
		assign_next_capturable_base_to_units_init()

func check_for_next_capturable_bases():
	for entity in unit_container.get_children():
		var next_base = get_next_capturable_base(entity)
		if next_base != null:
			target_offensive_base = next_base
			assign_next_capturable_base_to_units(next_base, entity)
		else:
			print("No next_base found in check_for_next_capturable_bases() MapAI")

func check_for_next_defendable_base():
	for entity in unit_container.get_children():
		var next_base = get_next_defendable_base(entity)
		if next_base != null:
			target_defensive_base = next_base
			assign_next_capturable_base_to_units(next_base, entity)
		else:
			print("No next_base found in check_for_next_defendable_base() MapAI")

func get_next_capturable_base(enemy):	#Looks for next available base with the highest priority
	var list_of_bases = range(capturable_bases.size()) 
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1,  -1, -1)
	capturable_bases.sort_custom(distance_sort.bind(enemy))
	#capturable_bases.sort_custom(priority_sort)
	for i in list_of_bases:
		var base = capturable_bases[i]
		if enemy.team.team != base.team.team and base.enemy_unit_count < base.capture_size:
			return base
	return null

func get_next_capturable_base_init():
	for enemy in unit_container.get_children():
		capturable_bases.sort_custom(priority_sort)
		capturable_bases.sort_custom(distance_sort.bind(enemy))
		for base in capturable_bases:
			# base.priority
			if team.team != base.team.team and base.enemy_unit_count < base.capture_size:
				return base
	return null

func get_next_defendable_base(enemy):	#Looks for next defendable base with the highest priority
	var list_of_bases = range(capturable_bases.size()) 
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1,  -1, -1)
		
	capturable_bases.sort_custom(distance_sort.bind(enemy))
	capturable_bases.sort_custom(priority_sort)
	for i in list_of_bases:
		var base = capturable_bases[i]
		# base.priority
		if team.team == base.team.team and base.enemy_unit_count < base.capture_size:
			return base
	return null

func priority_sort(a, b):
	return a.capture_priority < b.capture_priority
func distance_sort(a, b, enemy):
	return enemy.position.distance_to(a.position) < enemy.position.distance_to(b.position)
	
func assign_next_capturable_base_to_units(_base, entity):
	if entity.ai.type == AI.AIType.CAPTURER:	#Checks if enemy is a capturer
		set_unit_ai_to_advance_next_base(entity)

func assign_next_capturable_base_to_units_init():
	for entity in unit_container.get_children():
		#if entity.ai.type == AI.AIType.CAPTURER:	#Checks if enemy is a capturer
		set_unit_ai_to_advance_next_base(entity)

func assign_next_defendable_base_to_units(_base):
		
	for entity in unit_container.get_children():
		if entity.ai.type == AI.AIType.DEFENDER:	#Checks if enemy is a defender
			set_unit_ai_to_advance_next_base(entity)

func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instantiate()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died",handle_unit_death)
	unit_instance.ai.pathfinding = pathfinding
	unit_instance.ai.player = player_unit
	var random = randf_range(0.0, 1.0)
	if random <= capturer_coeficient:
		unit_instance.ai.type = AI.AIType.CAPTURER
	elif random <= (capturer_coeficient + defender_coeficient) and random > capturer_coeficient:
		unit_instance.ai.type = AI.AIType.DEFENDER
	elif random <= 1 and random > (capturer_coeficient + defender_coeficient):
		unit_container.ai.type = AI.AIType.SEEKER
	
	set_unit_ai_to_advance_next_base(unit_instance)
	GlobalSignals.emit_signal("enemy_spawned",unit_container.get_children().size())
	
func set_unit_ai_to_advance_next_base(unit_temp: Actor):
	if unit_temp.ai.type == AI.AIType.CAPTURER:
		if target_offensive_base != null:
			var ai: AI = unit_temp.ai
			ai.next_objective = target_offensive_base.get_random_position_within_radius()
			ai.set_state(AI.State.ADVANCE)
	elif unit_temp.ai.type == AI.AIType.DEFENDER:
		if target_defensive_base != null:
			var ai: AI = unit_temp.ai
			ai.next_objective = target_defensive_base.get_random_position_within_radius()
			ai.set_state(AI.State.ADVANCE)

func set_unit_ai_to_advance_next_defensive_base(unit_temp: Actor):
	if target_defensive_base != null:
		unit_temp.ai.next_objective = target_defensive_base.get_random_position_within_radius()
		unit_temp.ai.set_state(AI.State.ADVANCE)

func handle_unit_death():
	var unit_size = unit_container.get_children().size() - 1
	GlobalSignals.emit_signal("enemy_spawned",unit_container.get_children().size())
	if respawn_timer.is_stopped() and unit_size < max_units_alive:
		respawn_timer.start()
		return
	
func _on_respawn_timer_timeout():
	
	for i in enemy_per_wave:
		if unit_container.get_children().size() < max_units_alive:
			var respawn = respawn_points[next_spawn_to_use]
			spawn_unit(respawn.global_position)
			next_spawn_to_use += 1
			if next_spawn_to_use >= respawn_points.size():
				next_spawn_to_use = 0
			respawn_timer.start()
			
		
func update_data(max_units_alive_temp, capturer_coeficient_temp, defender_coeficient_temp, seeker_coeficient_temp): #Recieve new information from Director
	max_units_alive = max_units_alive_temp
	capturer_coeficient = capturer_coeficient_temp
	defender_coeficient = defender_coeficient_temp
	seeker_coeficient = seeker_coeficient_temp
	pass
		
