class_name MoveComponent
extends Node

@export var gravity: float = 3000.0
@export var speed: float = 30.0
@onready var parent: CharacterBody2D = get_parent()
@onready var rightcollision: RayCast2D = $"../rightcollision"
@onready var leftcollision: RayCast2D = $"../leftcollision"


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_push_movement()
	parent.move_and_slide()
	
func _apply_gravity(delta:float)-> void:
	if not parent.is_on_floor():
		parent.velocity.y+= gravity*delta

func _push_movement()-> void:
	var direction = Input.get_axis("move_left","move_right")
	if direction == _get_collision_normal() and direction:
		parent.velocity.x = speed*-direction
	else:
		parent.velocity.x=0.0

func _get_collision_normal() -> float:
	if leftcollision.is_colliding(): return 1.0
	elif rightcollision.is_colliding(): return -1.0
	else: return 0.0

func _is_interactable()-> float:
	return leftcollision.is_colliding() or rightcollision.is_colliding()

func _get_collider()-> Fighter:
	for ray in [leftcollision,rightcollision]:
		if ray.is_colliding() and ray.get_collider() is Fighter:
			return ray.get_collider()
	return null
