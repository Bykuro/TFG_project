extends CharacterBody2D
class_name Player

const SPEED 		= 300


@onready var health_stat = $Health
@onready var weapon = $Weapon
@onready var team = $Team
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func get_input():
	var input_dir = Input.get_vector("left","right","up","down")
	velocity = input_dir * SPEED
	
func _physics_process(_delta):	
	get_input()
	move_and_slide()
	look_at(get_global_mouse_position())


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		weapon.shoot()
	elif event.is_action_pressed("reload"):
		weapon.start_reload()

func get_team() ->int:
	return team.team


func reload():
	weapon.start_reload()


func handle_hit():
	health_stat.health -=20
	print("player hit!")
