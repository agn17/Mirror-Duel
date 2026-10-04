class_name PushBox
extends CharacterBody2D

@export var gravity := 1100.0
@export var friction := 1200.0

var push_velocity := 0.0

func push(vx: float) -> void:
	push_velocity = vx

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = push_velocity
	move_and_slide()
	push_velocity = 0.0   # must be re-applied every frame to keep moving
