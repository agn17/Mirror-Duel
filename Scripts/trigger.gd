class_name Trigger
extends Area2D

signal toggled(active: bool)

@export var group := "mirror"        # who can press it: "mirror", "player" or "pushable"
@export var latch := false           # stay on after the first press
@export var linger := 0.5            # stay on this long after leaving
@export var targets: Array[Node] = []  # drag targets here in the Inspector

var count := 0
var timer := 0.0
var active := false

func _ready() -> void:
	body_entered.connect(func(b): if b.is_in_group(group): count += 1)
	body_exited.connect(func(b): if b.is_in_group(group): count -= 1)
	toggled.connect(_notify_targets)

func _physics_process(delta: float) -> void:
	if latch and active:
		return
	timer = linger if count > 0 else max(0.0, timer - delta)
	var now := count > 0 or timer > 0.0
	if now != active:
		active = now
		toggled.emit(active)

func _notify_targets(on: bool) -> void:
	for t in targets:
		if t and t.has_method("set_active"):
			t.set_active(on)
