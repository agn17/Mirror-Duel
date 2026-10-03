class_name Fighter
extends CharacterBody2D

signal attacked
signal damaged(health: int)
signal died
signal jumped

@onready var sprite: AnimatedSprite2D = $Body
@export var speed := 200.0
@export var jump_velocity := -380.0
@export var gravity := 1100.0
@export var max_health := 3

var step_timer := 0.0
@onready var step_sound: AudioStreamPlayer2D = $StepSound
var health: int
var facing := Vector2.RIGHT
var attack_cooldown := 0.0
var invuln := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var attacking:=false
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	health = max_health
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func apply_frame(f: Dictionary, delta: float) -> void:
	attack_cooldown = max(0.0, attack_cooldown - delta)
	invuln = max(0.0, invuln - delta)

	if is_on_floor():
		coyote = 0.1
	else:
		coyote -= delta
		velocity.y += gravity * delta
	jump_buffer = 0.1 if f.jump else jump_buffer - delta

	velocity.x = f.x * speed
	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = jump_velocity
		coyote = 0.0
		jump_buffer = 0.0
		jumped.emit()

	if f.x != 0.0:
		facing = Vector2(sign(f.x), 0)
	move_and_slide()

	if f.attack and attack_cooldown == 0.0:
		_do_attack()
		_do_attack()
	_update_animation()
	_update_steps(delta)
	
func _update_animation() -> void:
	if attacking:
		_play("attack")
	elif not is_on_floor():
		_play("jump")
	elif abs(velocity.x)>1.0:
		_play("run")
	else:
		_play("idle")
	sprite.flip_h=facing.x<0.0

func _play(anim:String)-> void:
	if sprite.animation!=anim:
		sprite.play(anim)

func _update_steps(delta: float) -> void:
	if is_on_floor() and abs(velocity.x) > 1.0:
		step_timer -= delta
		if step_timer <= 0.0:
			step_timer = 0.3
			step_sound.pitch_scale = randf_range(0.9, 1.1)
			step_sound.play()
	else:
		step_timer = 0.0

func _do_attack() -> void:
	attack_cooldown = 0.5
	attacking = true
	hitbox.position = Vector2(facing.x * 40.0, -22.0)
	hitbox.set_deferred("monitoring", true)
	attacked.emit()
	await get_tree().create_timer(0.15).timeout
	hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(0.1).timeout
	attacking = false
func _on_hitbox_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target != self and target is Fighter:
		target.take_hit()

func take_hit() -> void:
	if invuln > 0.0:
		return
	invuln = 0.6
	health -= 1
	damaged.emit(health)
	if health <= 0:
		died.emit()
