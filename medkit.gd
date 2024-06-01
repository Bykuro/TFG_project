extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.carried_meds < 3:
			body.handle_pickup_medkit()
			queue_free()
