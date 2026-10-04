extends Node2D

const speed=60

var direction = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_castright.is_colliding():
		direction=-1
		animated_sprite_2d.flip_h=true
	if ray_castleft.is_colliding():
		direction=1
		animated_sprite_2d.flip_h=false

	position.x+= direction*speed*delta
