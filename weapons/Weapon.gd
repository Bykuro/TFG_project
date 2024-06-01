extends Node2D

class_name Weapon

signal weapon_out_of_ammo

@export var bullet 	: PackedScene
var max_ammo = 20
var mag_ammo = 10

@onready var end_of_gun = $EndOfGun
@onready var gun_direction = $GunDirection
@onready var attack_cooldown = $AttackCooldown
@onready var animation_player = $AnimationPlayer
@onready var muzzle_flash = $MuzzleFlash
# Called when the node enters the scene tree for the first time.

func _ready():
	muzzle_flash.hide()


func start_reload():
	animation_player.play("reload")

func _stop_reload():
	var bullets_to_reload = 10 - mag_ammo
	if max_ammo > 0:
		if max_ammo <= bullets_to_reload:
			mag_ammo += max_ammo
			max_ammo = 0
		else:
			mag_ammo += bullets_to_reload
			max_ammo -= bullets_to_reload
	GlobalSignals.emit_signal("update_ammo")

func shoot(precision_value):
	if attack_cooldown.is_stopped() and Bullet != null and mag_ammo > 0:
		var bullet_instance = bullet.instantiate()
		var misdirection: Vector2 = Vector2(randf_range(-precision_value, precision_value), randf_range(-precision_value, precision_value))
		var direction = (gun_direction.global_position - end_of_gun.global_position + misdirection).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction)
		attack_cooldown.start()
		animation_player.play("muzzle_flash")
		mag_ammo -= 1
		if mag_ammo <= 0:
			emit_signal("weapon_out_of_ammo")

func gain_ammo():
	max_ammo += 8
	GlobalSignals.emit_signal("update_ammo")
