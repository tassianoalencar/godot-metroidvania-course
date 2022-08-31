class_name Player
extends KinematicBody2D

"""
01. tool
02. class_name
03. extends
04. # docstring

05. signals
06. enums
07. constants
08. exported variables
09. public variables
10. private variables
11. onready variables

12. optional built-in virtual _init method
13. built-in virtual _ready method
14. remaining built-in virtual methods
15. public methods
16. private methods
"""

# Pacotes
const DustEffect: PackedScene = preload("res://src/effects/DustEffect.tscn")

# Movimentações na plataforma
export(int) var max_speed = 65
export(int) var acceleration = 512
export(float) var friction = 0.25
export(int) var max_jump = 2

# Gravidades
export(int) var gravity = 256
export(int) var jump_force = 128
export(int) var max_slop_angle = 45

var motion: Vector2 = Vector2.ZERO
var jump_count: int = 0
var snap_vector: Vector2 = Vector2.ZERO
var snap_slide: int = 4
var is_jumping: bool = false

onready var spriteAnimator: AnimationPlayer = $SpriteAnimator
onready var sprite: Sprite = $Sprite


func _physics_process(delta: float) -> void:
	is_jumping = false
	var input_vector: Vector2 = _get_input_vector()
	_apply_horizontal_acceleration(input_vector, delta)
	_apply_friction(input_vector)
	_update_snap_vector()
	_jump_check()
	_apply_gravity(delta)
	_update_animations(input_vector)
	_move()


# Retorna um vetor2 com base na tecla apertada
func _get_input_vector() -> Vector2:
	return Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0)


# Aplica aceleração horizontal
func _apply_horizontal_acceleration(input_vector: Vector2, delta: float) -> void:
	if input_vector.x != 0:
		motion.x += input_vector.x * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)


# Aplica fricção de parada
func _apply_friction(input_vector: Vector2) -> void:
	if input_vector.x == 0 and is_on_floor():
		motion.x = lerp(motion.x, 0, friction)


func _update_snap_vector() -> void:
	if is_on_floor():
		snap_vector = Vector2.DOWN


# Zera o verifica se o player quer pular
func _jump_check() -> void:
	if is_on_floor():
		jump_count = 0
	else:
		if Input.is_action_just_released("jump") and motion.y < -jump_force/2:
			motion.y = -jump_force/2

	if Input.is_action_just_pressed("jump"):
		if jump_count < max_jump:
			motion.y = -jump_force
			is_jumping = true
			jump_count += 1
			snap_vector = Vector2.ZERO


# Aplica a gravidade quando está no ar
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		motion.y += gravity * delta
		motion.y = min(motion.y, jump_force)


func _update_animations(input_vector: Vector2) -> void:
	sprite.scale.x = sign(get_local_mouse_position().x)
	
	if input_vector.x != 0:
		spriteAnimator.play("Walk")
		spriteAnimator.playback_speed = input_vector.x * sprite.scale.x
	else:
		spriteAnimator.playback_speed = 1
		spriteAnimator.play("Idle")
	
	if not is_on_floor():
		spriteAnimator.play("Jump")


# Cria o efeito dust
func _create_dust_effect() -> void:
	var effect_position: Vector2 = global_position
	var dustEffect: Node2D = DustEffect.instance()
	
	get_tree().current_scene.add_child(dustEffect)
	dustEffect.global_position = effect_position


# Movimenta o player
func _move() -> void:
	var was_in_air = not is_on_floor()
	var was_on_floor: bool = is_on_floor()
	
	var last_motion: Vector2 = motion
	var last_position: Vector2 = position

	motion = move_and_slide_with_snap(motion, snap_vector * snap_slide, Vector2.UP, true, snap_slide, deg2rad(max_slop_angle))

	if was_in_air and is_on_floor():
		motion.x = last_motion.x

	if was_on_floor and not is_on_floor() and not is_jumping:
		motion.y = 0
		position.y = last_position.y
























