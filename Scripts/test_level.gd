extends Node2D

func _ready() -> void:
	$Player.frame_ready.connect($MirrorEnemy.mirror_frame)
