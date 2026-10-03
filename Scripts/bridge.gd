extends StaticBody2D
func _ready() -> void:
	set_extended(false)

func set_extended(on: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not on)
	create_tween().tween_property(self, "modulate:a", 1.0 if on else 0.15, 0.2)
