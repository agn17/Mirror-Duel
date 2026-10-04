class_name Plate
extends Area2D

signal toggled(active: bool)

@export var linger := 1.2
@export var latch := false
@export var required_group := "mirror"

var occupants := 0
var timer := 0.0
var active := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("mirror"):
		occupants += 1

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("mirror"):
		occupants -= 1

func _physics_process(delta: float) -> void:
	if latch and active:
		return
	timer = linger if occupants > 0 else max(0.0, timer - delta)
	var now := timer > 0.0
	if now != active:
		active = now
		toggled.emit(active)
