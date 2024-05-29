extends Node2D


class_name AI

signal state_changed(new_state)

enum AIType{
	CAPTURER,
	DEFENDER,
	SEEKER
}

enum State{
	PATROL,
	ENGAGE,
	ADVANCE
}


@onready var player_detection_zone = $PlayerDetection
@onready var patrol_timer = $PatrolTimer

var type : AIType
var current_state: int = -1 : set = set_state
var actor: Actor = null
var player: Player = null
var weapon: Weapon = null

#PATROL STATE
var origin = Vector2.ZERO
var patrol_location = Vector2.ZERO
var patrol_location_reached = false

#ADVANCE STATE
var next_base = Vector2.ZERO

var pathfinding: Pathfinding

func _ready():
	set_state(State.PATROL)
	

func _physics_process(_delta):
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
				actor.rotate_toward(player.global_position)
				var angle_to_player =  actor.global_position.direction_to(player.global_position).angle()
				if abs(actor.rotation - angle_to_player) < 0.1:
					weapon.shoot()
			else:
				print("Engage entered, yet no weapon // player")
		State.ADVANCE:
			var path = pathfinding.get_new_path(global_position, next_base)
			if path.size() > 1: 
				actor.velocity = actor.velocity_toward(path[1])
				actor.rotate_toward(path[1])
				actor.move_and_slide() 
			else:
				set_state(State.PATROL)
		_:
			print("Error: Found non existent state in enemy")


func initialize(actor_temp, weapon_temp : Weapon):
	self.actor = actor_temp
	self.weapon = weapon_temp
	weapon.weapon_out_of_ammo.connect(self.handle_reload)

func set_state(new_state: int):
	if new_state == current_state:
		return
	if new_state == State.PATROL:
		origin = global_position
		patrol_timer.start()
		patrol_location_reached = true
	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_base):
			set_state(State.PATROL)
	
	current_state = new_state
	emit_signal("state_changed", current_state)




func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		set_state(State.ENGAGE)
		player = body
	


func _on_player_detection_body_exited(body):
	if player and body == player:
		set_state(State.ADVANCE)
		player = null

func handle_reload():
	weapon.start_reload()


func _on_patrol_timer_timeout():
	var patrol_range = 200
	var random_x = randf_range(-patrol_range, patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	patrol_location_reached = false
	
