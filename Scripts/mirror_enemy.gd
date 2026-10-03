extends Fighter

func _ready() -> void:
	super._ready()
	add_to_group("mirror")
	facing = Vector2.LEFT

func mirror_frame(f: Dictionary) -> void:
	var m := f.duplicate()
	m.x = -f.x
	apply_frame(m, get_physics_process_delta_time())
