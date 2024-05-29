extends Area2D




func _on_body_entered(body):
	if body.has_method("handle_reload"):
		body.handle_reload()
		queue_free()
