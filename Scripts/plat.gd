extends StaticBody2D

@export var solid_when_active := true   # true = bridge, false = door
@export var start_active := false

func _ready() -> void:
	set_active(start_active)

func set_active(on: bool) -> void:
	var solid := on if solid_when_active else not on
	$CollisionShape2D.set_deferred("disabled", not solid)
	create_tween().tween_property(self, "modulate:a", 1.0 if solid else 0.15, 0.2)
