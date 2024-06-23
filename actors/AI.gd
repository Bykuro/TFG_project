extends Node2D


class_name AI

signal state_changed(new_state)

enum AIType{
	CAPTURER,
	DEFENDER,
	SEEKER,
	NULL
}

enum State{
	PATROL,
	ENGAGE,
	ADVANCE,
	SEEK
}


@onready var player_detection_zone = $PlayerRaycastDetection
@onready var patrol_timer = $PatrolTimer

var type : AIType = AIType.CAPTURER
var current_state: int = -1 : set = set_state
var actor: Actor = null
var player: CharacterBody2D = null
var weapon: Weapon = null
var precision_value = 5
var boolean_timer = false
@onready var time_alert = $AlertTimer
#PATROL STATE
var origin = Vector2.ZERO
var patrol_location = Vector2.ZERO
var patrol_location_reached = false

#ADVANCE STATE
var next_objective = Vector2.ZERO

#SEEK STATE
var pos_deviation = 50
var pathfinding: Pathfinding
var detection: Array
func generate_raycasts():
	detection = player_detection_zone.get_children()

func _ready():
	set_state(State.PATROL)
	generate_raycasts()
	time_alert.wait_time = 2
	
func _physics_process(_delta):
	detect_player()
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				var path = pathfinding.get_new_path(global_position, patrol_location)
				if path.size() > 1: 
					actor.velocity = actor.velocity_toward(path[1])
					actor.rotate_toward(path[1])
					actor.move_and_slide() 
				else:
					patrol_location_reached = true
					actor.velocity = Vector2.ZERO
					patrol_timer.start()
		State.ENGAGE:
			if player != null and weapon != null:
				if is_in_sight():
					boolean_timer = false 
				actor.rotate_toward(player.global_position)
				var angle_to_player =  actor.global_position.direction_to(player.global_position).angle()
				if abs(actor.rotation - angle_to_player) < 0.1 and is_in_sight():
					weapon.shoot(precision_value)
					time_alert.stop()
			else:
				print("Engage entered, yet no weapon // player")
			if !is_in_sight():
				if time_alert.is_stopped() and !boolean_timer:
					time_alert.start()
					boolean_timer = true
					
		State.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_objective)
			if path.size() > 1: 
				actor.velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.move_and_slide() 
			else:
				set_state(State.PATROL)
		State.SEEK:
			var path = pathfinding.get_new_path(global_position, player.global_position)
			if path.size() > 1: 
				actor.velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.move_and_slide() 
			else:
				print("Could not find path")
		_:
			print("Error: Found non existent state in enemy")

func on_alert_timeout():
	set_state(State.ADVANCE)

func initialize(actor_temp, weapon_temp : Weapon):
	self.actor = actor_temp
	self.weapon = weapon_temp
	weapon.max_ammo = 999
	weapon.weapon_out_of_ammo.connect(self.handle_reload)
	GlobalSignals.send_config_values.connect(get_new_precision_value)
	
func get_new_precision_value(new_config):
	precision_value = new_config.precision_value

func set_state(new_state: int):
	if new_state == current_state:
		return
	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_objective):
			set_state(State.PATROL)
	
	current_state = new_state
	emit_signal("state_changed", current_state)

func detect_player():
	for i in detection:
		if i.is_colliding():
			if i.get_collider() == player:
				set_state(State.ENGAGE)

func is_in_sight():
	for i in detection:
		if i.is_colliding():
			if i.get_collider() == player:
				return true
	return false
	
func handle_reload():
	weapon.start_reload()


func _on_patrol_timer_timeout():
	var patrol_range = 150
	var random_x = randf_range(-patrol_range, patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false
	


func _on_alert_timer_timeout():
	if type == AIType.SEEKER:
		set_state(State.SEEK)
	else:
		set_state(State.ADVANCE)
