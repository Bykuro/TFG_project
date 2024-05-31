extends Area2D



class_name Bullet


const SPEED = 40.0
var direction := Vector2.ZERO
@onready var kill_timer = $KillTimer


func _ready():
	kill_timer.start()


func _physics_process(_delta):
	if direction != Vector2.ZERO:
		var velocity = direction * SPEED
		global_position += velocity
	
func set_direction(direction_temp: Vector2):
	self.direction = direction_temp
	rotation += direction.angle()


func _on_kill_timer_timeout():
	queue_free()
	queue_free()

func _on_body_entered(body):
	if body.has_method("handle_hit"):
		body.handle_hit()
		queue_free()
	if body.is_in_group("obstacles"):
		queue_free()
