extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false;
var just_wall_jumped = false;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer



# delta: 초당 물리틱, 설정에서 현재 60으로 맞춰져있음 -> 1초에한번씩 동작
func _physics_process(delta):
	apply_gravity(delta)
	
	handle_wall_jump()
	handle_jump()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis = Input.get_axis("move_left", "move_right")
	
	handle_acceleration(input_axis, delta)	
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	
	move_and_slide()
	
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	if Input.is_action_just_pressed("jump"):
		movement_data = load("res://Player/FasterMovementData.tres")
	just_wall_jumped = false	
	
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()
		
	update_animations(input_axis)
	

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta


func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: return;
	var wall_normal = get_wall_normal()
	
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	
	if Input.is_action_just_pressed("jump"): # and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.spead
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
#	if Input.is_action_just_pressed("ui_up") and wall_normal == Vector2.RIGHT:
#		velocity.x = wall_normal.x * movement_data.spead
#		velocity.y = movement_data.jump_velocity


func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
			
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false
 

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return; # 공중에서 방향전환 막음
	if input_axis != 0:
		velocity.x = move_toward(
			velocity.x, movement_data.spead * input_axis, movement_data.acceleration * delta)
		# velocity.x = direction * SPEED


func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return;
	if input_axis != 0:
		velocity.x = move_toward(
			velocity.x, movement_data.spead * input_axis, movement_data.air_acceleration * delta)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.x = 0
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistence * delta)


func update_animations(input_axis):
	if input_axis != 0: #moving
		# 여기서 방향이 바뀌므로 점프와 조건문을 분리하여야 함 -> 그래야 공중에서도 방향 전환이 됨
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")	
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position = starting_position
