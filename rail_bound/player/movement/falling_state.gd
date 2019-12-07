extends MovementState

class_name FallingState

func _init(player_ref).(player_ref):
	if player.velocity.y <= 0:
		player.set_animation("jumping");
		player.set_collision("IdleCollision");
	else:
		if Input.is_action_pressed("slide"):
			player.set_animation("sliding");
			player.set_collision("SlideCollision");
		else:
			player.set_animation("falling");
			player.set_collision("IdleCollision");

func move(delta):
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func get_input():
	player.velocity.y += player.gravity;
	
	if Input.is_action_pressed("move_left"):
		player.velocity.x -= player.air_acceleration;
	elif Input.is_action_pressed("move_right"):
		player.velocity.x += player.air_acceleration;
	
	if player.velocity.x < 0:
		player.get_node("AnimatedSprite").flip_h = true;
	else:
		player.get_node("AnimatedSprite").flip_h = false;
	
	if player.velocity.y - player.gravity > 0:
		if Input.is_action_pressed("slide"):
			player.set_animation("sliding");
			player.set_collision("SlideCollision");
		else:
			player.set_animation("falling");
	if player.velocity.y > 0:
		if Input.is_action_just_pressed("slide"):
			player.set_animation("sliding");
			player.set_collision("SlideCollision");
		elif Input.is_action_just_released("slide"):
			player.set_animation("falling");
			player.set_collision("IdleCollision");
	
	if player.is_on_wall() and not Input.is_action_pressed("slide"):
		player.set_movement_state("climbing");
	elif player.is_on_floor():
		player.set_movement_state("running");
	

func get_collisions():
	pass;