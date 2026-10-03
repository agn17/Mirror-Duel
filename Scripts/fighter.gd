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

var health: int
var facing := Vector2.RIGHT
var attack_cooldown := 0.0
var invuln := 0.0
var bowing := false
var coyote := 0.0
var jump_buffer := 0.0

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	health = max_health
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func apply_frame(f: Dictionary, delta: float) -> void:
	if jump_buffer > 0.0 and coyote > 0.0 and not bowing:
		velocity.y = jump_velocity
		coyote = 0.0
		jump_buffer = 0.0
		jumped.emit()
	attack_cooldown = max(0.0, attack_cooldown - delta)
	invuln = max(0.0, invuln - delta)
	bowing = f.bow and is_on_floor()

	if is_on_floor():
		coyote = 0.1
	else:
		coyote -= delta
		velocity.y += gravity * delta
	jump_buffer = 0.1 if f.jump else jump_buffer - delta

	velocity.x = 0.0 if bowing else f.x * speed
	if jump_buffer > 0.0 and coyote > 0.0 and not bowing:
		velocity.y = jump_velocity
		coyote = 0.0
		jump_buffer = 0.0

	if f.x != 0.0 and not bowing:
		facing = Vector2(sign(f.x), 0)
	move_and_slide()

	if f.attack and attack_cooldown == 0.0 and not bowing:
		_do_attack()

func _do_attack() -> void:
	attack_cooldown = 0.5
	hitbox.position = Vector2(facing.x * 40.0, -22.0)
	hitbox.set_deferred("monitoring", true)
	attacked.emit()
	await get_tree().create_timer(0.15).timeout
	hitbox.set_deferred("monitoring", false)

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
