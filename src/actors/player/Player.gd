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

# Movimentações na plataforma
export(int) var max_speed = 65
export(int) var acceleration = 512
export(float) var friction = 0.25
export(int) var max_jump = 1

# Gravidades
export(int) var gravity = 200
export(int) var jump_force = 128
export(int) var max_slop_angle = 45

var motion: Vector2 = Vector2.ZERO
var jump_count:int = 0


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = _get_input_vector()
	_apply_horizontal_acceleration(input_vector, delta)
	_apply_friction(input_vector)
	_jump_check(delta)
	_apply_gravity(delta)
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


# Zera o verifica se o player quer pular
func _jump_check(delta: float) -> void:
	if is_on_floor():
		jump_count = 0
	else:
		if Input.is_action_just_released("jump") and motion.y < -jump_force/2:
			motion.y = -jump_force/2

	if Input.is_action_just_pressed("jump"):
		if jump_count < max_jump:
			motion.y = -jump_force
			jump_count += 1


# Aplica a gravidade quando está no ar
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		motion.y += gravity * delta
		motion.y = min(motion.y, jump_force)


# Movimenta o player
func _move() -> void:
	motion = move_and_slide(motion, Vector2.UP)

























