extends Area2D



@export var neutral_color = Color(1,1,1)
@export var player_color = Color(0.192157, 0.486275, 0.207843)
@export var enemy_color = Color(0.337255, 0.360784, 0.643137)

var enemies_on_site: Array
var enemy_unit_count = 0
var team_to_capture = Team.TeamName.NEUTRAL
var time_captured = Timer.new()

@onready var capture_priority = 2 # 3 == LOW , 2 == NORMAL , 1 == HIGH
@onready var capture_size = 3
@onready var player_unit_count = 0
@onready var collision_shape = $CollisionShape2D
@onready var team = $Team
@onready var capture_timer = $CaptureTimer
@onready var sprite = $Sprite2D

func _ready():
	add_child(time_captured)
	time_captured.wait_time = 300.0

func get_random_position_within_radius() -> Vector2:
	var extents = collision_shape.shape.extents
	var top_left = collision_shape.global_position - extents / 2
	var x = randf_range(top_left.x, top_left.x + extents.x)
	var y = randf_range(top_left.y, top_left.y + extents.y)
	
	return Vector2(x,y)
	
func _on_body_entered(body):
	
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemies_on_site.append(body)
			enemy_unit_count += 1
		if body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
			
	check_whether_base_can_be_captured()


func _on_body_exited(body):
	if body.has_method("get_team"):
		var body_team = body.get_team()
		if body_team == Team.TeamName.ENEMY:
			enemies_on_site.erase(body)
			enemy_unit_count -= 1
		if body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1
			
	check_whether_base_can_be_captured()

func check_whether_base_can_be_captured():
	var majority_team = get_team_majority()
	if majority_team == Team.TeamName.NEUTRAL:
		return
	elif majority_team == team.team:
		team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
	else:
		team_to_capture = majority_team
		if capture_timer.is_stopped():
			capture_timer.start()
	

func get_team_majority() -> int:
		print(enemy_unit_count)
		if enemy_unit_count == player_unit_count:
			return Team.TeamName.NEUTRAL
		elif enemy_unit_count > player_unit_count:
			return Team.TeamName.ENEMY
		else:
			return Team.TeamName.PLAYER

func set_team(new_team: int):
	team.team = new_team
	GlobalSignals.emit_signal("base_captured", enemies_on_site)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
			return
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
			return
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
			return

func _on_capture_timer_timeout():
	if team_to_capture == Team.TeamName.PLAYER and player_unit_count > 0:
		set_team(team_to_capture)
	elif team_to_capture == Team.TeamName.ENEMY and enemy_unit_count > 0:
		set_team(team_to_capture)
	time_captured.start()
