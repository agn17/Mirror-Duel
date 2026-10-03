extends Node2D

@onready var player: Fighter = $Player
@onready var enemy: Fighter = $MirrorEnemy
@onready var exit_pad: Area2D = $ExitPad
@onready var message: Label = $UI/Message

var hold := 0.0
var finished := false
var attack_count := 0

func _ready() -> void:
	player.frame_ready.connect(enemy.mirror_frame)
	player.attacked.connect(func(): attack_count += 1)
	$Plate.toggled.connect($Bridge.set_extended)

	# Pacifist rule: any damage to either fighter = fail
	player.damaged.connect(func(_h): _lose())
	enemy.damaged.connect(func(_h): _lose())
	$Killzone.body_entered.connect(func(_b): _lose())

func _physics_process(delta: float) -> void:
	if finished:
		return
	if exit_pad.overlaps_body(player) and player.bowing and enemy.bowing:
		hold += delta
	else:
		hold = 0.0
	if hold >= 1.5:
		_win()

func _win() -> void:
	finished = true
	player.set_physics_process(false)
	message.text = "Nobody got hurt.\nYou attacked %d times." % attack_count

func _lose() -> void:
	if finished:
		return
	finished = true
	get_tree().reload_current_scene.call_deferred()
