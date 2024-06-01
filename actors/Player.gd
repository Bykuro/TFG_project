extends CharacterBody2D
class_name Player

signal player_died
signal player_health_change(new_health)
const SPEED 		= 300

@onready var collision_shape = $Hitbox
@onready var health_stat = $Health
@onready var weapon = $Weapon
@onready var team = $Team
@onready var camera_transform = $CameraTransform
var carried_meds = 2
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	GlobalSignals.add_ammo.connect(handle_reload)

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
		GlobalSignals.emit_signal("update_ammo")
	elif event.is_action_pressed("reload"):
		weapon.start_reload()
	elif event.is_action_pressed("medkit"):
		handle_healing()
		

func set_camera_transform(camera_path: NodePath):
	camera_transform.remote_path = camera_path


func get_team() ->int:
	return team.team


func reload():
	weapon.start_reload()


func handle_hit():
	health_stat.health -= 10
	emit_signal("player_health_change", health_stat.health)
	if health_stat.health <= 0:
		player_death()

func player_death():
	emit_signal("player_died")
	queue_free()
	
func handle_healing():
	if carried_meds > 0:
		carried_meds -= 1
		health_stat.health += 40
		if health_stat.health < 100:
			health_stat.health = 100
		emit_signal("player_health_change", health_stat.health)
		GlobalSignals.emit_signal("medkit_action", carried_meds)

func handle_pickup_medkit():
	carried_meds +=1
	GlobalSignals.emit_signal("medkit_action", carried_meds)
	
func handle_reload():
	weapon.gain_ammo()
	GlobalSignals.emit_signal("update_ammo")
	pass

