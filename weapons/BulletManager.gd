extends Node2D

func handle_bullet_spawned(bullet: Bullet, new_position: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = new_position
	bullet.set_direction(direction)



