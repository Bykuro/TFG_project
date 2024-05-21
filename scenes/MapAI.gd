extends Node2D

enum BaseCaptureStartOrder {
	FIRST,
	LAST
}


@export var base_capture_start_order = BaseCaptureStartOrder.FIRST
@export var team_name = Team.TeamName.NEUTRAL	
@export var unit:PackedScene = null
@export var max_units_alive = 4

var pathfinding: Pathfinding
var target_base = null
var capturable_bases: Array =[]
var respawn_points:Array =[]
var next_spawn_to_use = 0

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
	
	check_for_next_capturable_bases()

func handle_base_captured(_new_team: int):
	check_for_next_capturable_bases()
	


func check_for_next_capturable_bases():
	var next_base = get_next_capturable_base()
	if next_base != null:
		target_base = next_base
		assign_next_capturable_base_to_units(next_base)


func get_next_capturable_base():
	var list_of_bases = range(capturable_bases.size()) 
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_bases = range(capturable_bases.size() - 1,  -1, -1)
		
	for i in list_of_bases:
		var base = capturable_bases[i]
		# base.priority
		if team.team != base.team.team:
			return base
	return null

func assign_next_capturable_base_to_units(base):
		
	for entity in unit_container.get_children():
		set_unit_ai_to_advance_next_base(entity)

func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instantiate()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died",handle_unit_death)
	unit_instance.ai.pathfinding = pathfinding
	set_unit_ai_to_advance_next_base(unit_instance)
	
func set_unit_ai_to_advance_next_base(unit_temp: Actor):
	if target_base != null:
		var ai: AI = unit_temp.ai
		ai.next_base = target_base.get_random_position_within_radius()
		ai.set_state(AI.State.ADVANCE)

func handle_unit_death():
	var unit_size = unit_container.get_children().size() - 1
	if respawn_timer.is_stopped() and unit_size < max_units_alive:
		respawn_timer.start()
		return
	
func _on_respawn_timer_timeout():
	if unit_container.get_children().size() < max_units_alive:
		var respawn = respawn_points[next_spawn_to_use]
		spawn_unit(respawn.global_position)
		next_spawn_to_use += 1
		if next_spawn_to_use >= respawn_points.size():
			next_spawn_to_use = 0
		respawn_timer.start()
		print("hello")
		
