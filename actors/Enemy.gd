extends CharacterBody2D

class_name Actor

signal died

const SPEED = 300.0
@onready var collision_shape = $Hitbox
@onready var health_stat = $Health
@onready var ai = $AI
@onready var weapon = $Weapon
@onready var team = $Team
@export var speed = 100

func _ready():
	ai.initialize(self, weapon)

func rotate_toward(location: Vector2):
	rotation = lerp(rotation, global_position.direction_to(location).angle(), 0.05)

func velocity_toward(location: Vector2):
	return global_position.direction_to(location) * speed

func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < 5

func get_team() -> int:
	return team.team
	
func handle_hit():
	health_stat.health -=20
	if health_stat.health <= 0:
		emit_signal("died")
		GlobalSignals.emit_signal("spawn_item",self.global_position)
		queue_free()
