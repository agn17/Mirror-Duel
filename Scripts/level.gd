extends Node2D

const FAIL_HINTS := [
	"It only does what you do...",
	"It walks the opposite way. Where could that take it?",
	"Something on its side might help you.",
]

@onready var player: Fighter = $Player
@onready var enemy: Fighter = $MirrorEnemy
@onready var exit_pad: Area2D = $ExitPad
@onready var hint: Label = $UI/Hint
@onready var cam: Camera2D = $Camera2D
@onready var plate_rect: ColorRect = $Plate/ColorRect
@onready var dim: ColorRect = $UI/Dim
@onready var win_box: VBoxContainer = $UI/Winbox
@onready var win_title: Label = $UI/Winbox/Title
@onready var win_stats: Label = $UI/Winbox/Stat
@onready var win_prompt: Label = $UI/Winbox/Prompt

var hold := 0.0
var finished := false
var can_restart := false
var attack_count := 0

func _ready() -> void:
	dim.modulate.a = 0.0
	win_box.visible = false
	plate_rect.color = Color("8a7a1e")

	player.frame_ready.connect(enemy.mirror_frame)
	player.attacked.connect(_on_player_attacked)
	player.jumped.connect($Sfx/Jump.play)
	$Plate.toggled.connect(_on_plate_toggled)

	# Pacifist rule: any damage to either fighter = fail
	player.damaged.connect(_on_damaged)
	enemy.damaged.connect(_on_damaged)
	$Killzone.body_entered.connect(func(_b): _lose())

	if Game.deaths == 0:
		_show_hint("Move: A/D    Jump: Space/Up    Attack: J/X", 6.0)
	else:
		var i := mini(Game.deaths - 1, FAIL_HINTS.size() - 1)
		_show_hint(FAIL_HINTS[i], 5.0)

func _physics_process(delta: float) -> void:
	if finished:
		return
	if exit_pad.overlaps_body(player): #and player.attacking and enemy.attacking:
		hold += delta
	else:
		hold = 0.0
	if hold >= 1.5:
		_win()

func _on_player_attacked() -> void:
	attack_count += 1
	$Sfx/Attack.play()

func _on_plate_toggled(active: bool) -> void:
	plate_rect.color = Color("ffe94d") if active else Color("8a7a1e")
	$Bridge.set_extended(active)
	$Sfx/Plate.play()

func _on_damaged(_health: int) -> void:
	$Sfx/Hit.play()
	player.get_node("Body").modulate = Color.RED
	enemy.get_node("Body").modulate = Color.RED
	_lose()

func _show_hint(text: String, seconds: float) -> void:
	hint.text = text
	hint.modulate.a = 1.0
	var t := create_tween()
	t.tween_interval(seconds)
	t.tween_property(hint, "modulate:a", 0.0, 1.0)

func _shake(strength := 8.0) -> void:
	var t := create_tween()
	for i in 6:
		t.tween_property(cam, "offset",
			Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength, 0.04)
	t.tween_property(cam, "offset", Vector2.ZERO, 0.04)

func _win() -> void:
	finished = true
	player.set_physics_process(false)
	$Sfx/Win.play()

	win_title.text = "Nobody got hurt."
	if attack_count == 0:
		win_stats.text = "A true pacifist."
	else:
		win_stats.text = "You attacked %d time%s." % [attack_count, "" if attack_count == 1 else "s"]

	for l in [win_title, win_stats, win_prompt]:
		l.modulate.a = 0.0
	win_box.visible = true

	# Title pops in from slightly smaller
	win_title.pivot_offset = win_title.size / 2.0
	win_title.scale = Vector2(0.8, 0.8)
	create_tween().tween_property(win_title, "scale", Vector2.ONE, 0.6) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Sequence: dim, title, stats, prompt
	var t := create_tween()
	t.tween_property(dim, "modulate:a", 0.6, 0.5)
	t.tween_property(win_title, "modulate:a", 1.0, 0.6)
	t.tween_interval(0.3)
	t.tween_property(win_stats, "modulate:a", 1.0, 0.5)
	t.tween_interval(0.6)
	t.tween_property(win_prompt, "modulate:a", 1.0, 0.4)
	await t.finished
	can_restart = true
func _lose() -> void:
	if finished:
		return
	finished = true
	Game.deaths += 1
	player.set_physics_process(false)   # freezes the mirror too
	_shake()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if can_restart and event is InputEventKey and event.pressed and not event.echo:
		Game.deaths = 0
		get_tree().change_scene_to_file("res://Scenes/title.tscn")
