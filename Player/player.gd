extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false;
var just_wall_jumped = false;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position



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
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	if Input.is_action_just_pressed("jump"):
		movement_data = load("res://Player/FasterMovementData.tres")
	just_wall_jumped = false	

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta


func handle_wall_jump():
	if not is_on_wall_only(): return;
	var wall_normal = get_wall_normal()
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
	if not is_on_floor():
		animated_sprite_2d.play("jump")
	elif input_axis != 0: #moving
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")	


func _on_hazard_detector_area_entered(area):
	global_position = starting_position
