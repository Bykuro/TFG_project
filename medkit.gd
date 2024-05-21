extends Area2D


func _on_body_entered(body):
	if body.has_method("handle_healing"):
		body.handle_healing()
		queue_free()
