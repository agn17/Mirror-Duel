extends Control

func _ready() -> void:
	Game.deaths = 0
	var t := create_tween().set_loops()
	t.tween_property($Prompt, "modulate:a", 0.2, 0.8)
	t.tween_property($Prompt, "modulate:a", 1.0, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_tree().change_scene_to_file("res://Scenes/title.tscn")
