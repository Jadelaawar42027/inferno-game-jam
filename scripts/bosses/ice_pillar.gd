extends StaticBody2D


func _ready() -> void:
	SFX.play("icicle")
	scale.y = 0.0
	create_tween().tween_property(self, "scale:y", 1.0, 0.35)
	await get_tree().create_timer(8.0, false).timeout
	await create_tween().tween_property(self, "scale:y", 0.0, 0.3).finished
	queue_free()
