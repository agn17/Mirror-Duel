extends Fighter

signal frame_ready(frame: Dictionary)

func _physics_process(delta: float) -> void:
	var f := {
		"x": Input.get_axis("move_left", "move_right"),
		"jump": Input.is_action_just_pressed("jump"),
		"attack": Input.is_action_just_pressed("attack"),
		"bow": Input.is_action_pressed("bow"),
	}
	apply_frame(f, delta)
	frame_ready.emit(f)
