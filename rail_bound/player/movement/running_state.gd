extends MovementState

class_name RunningState

func _init(player_ref).(player_ref) -> void:
	if Input.is_action_pressed("slide"):
		player.start_sliding(true);
	else:
		player.set_animation("running");
		player.set_collision("IdleCollision");

func move(delta):
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func get_input():
	player.velocity.y += player.gravity;
	
	if Input.is_action_just_pressed("slide"):
		player.start_sliding(true);
	elif Input.is_action_just_released("slide"):
		player.set_animation("running");
		player.set_collision("IdleCollision");
	elif Input.is_action_pressed("slide"):
		if Input.is_action_pressed("move_left"):
			player.velocity.x += player.move_acceleration;
			if player.velocity.x > 0:
				player.velocity.x = 0;
		elif Input.is_action_pressed("move_right"):
			player.velocity.x -= player.move_acceleration;
			if player.velocity.x < 0:
				player.velocity.x = 0;
	elif Input.is_action_pressed("move_left"):
		if player.velocity.x > -1 * player.move_speed:
			player.velocity.x = -1 * player.move_speed;
		player.velocity.x -= player.move_acceleration;
		
		player.get_node("AnimatedSprite").flip_h = true;
		
		if player.is_left_raycast_colliding():
			player.set_movement_state("climbing");
	elif Input.is_action_pressed("move_right"):
		if player.velocity.x < player.move_speed:
			player.velocity.x = player.move_speed;
		player.velocity.x += player.move_acceleration;
		
		player.get_node("AnimatedSprite").flip_h = false;
		
		if player.is_right_raycast_colliding():
			player.set_movement_state("climbing");
			print("git");
	elif not Input.is_action_just_pressed("jump"):
		player.set_movement_state("idle");
	
	if Input.is_action_just_pressed("jump"):
		player.velocity.y -= player.jump_speed;
		player.set_movement_state("falling");
	
	if Input.is_action_just_released("slide") and player.get_node("CeilingRayCast").is_colliding():
		player.set_movement_state("rolling");
	
#	if player.is_on_wall() and not Input.is_action_pressed("slide"):
#		player.set_movement_state("climbing");
	
	if Input.is_action_just_pressed("railgun"):
		player.velocity = (player.get_global_mouse_position() - player.position).normalized() * player.railgun_speed;
		player.set_movement_state("railgun");

func get_collisions():
	if not player.is_on_floor():
		player.set_movement_state("falling");