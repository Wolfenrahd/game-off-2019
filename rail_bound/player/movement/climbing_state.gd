extends MovementState

class_name ClimbingState

var is_collision_left := false;

var count = 0;

func _init(player_ref).(player_ref):
	if player.velocity.y <= 0:
		player.set_animation("climbing_up");
	else:
		player.set_animation("climbing_down");
	
	for s in ["LeftRayCast1", "LeftRayCast2", "LeftRayCast3", "RightRayCast1", "RightRayCast2", "RightRayCast3"]:
		player.get_node(s).force_raycast_update();
	
	if player.is_left_raycast_colliding():
		player.get_node("ClimbCollision").position.x = -10;
		is_collision_left = true;
		player.get_node("AnimatedSprite").flip_h = true;
	elif player.is_right_raycast_colliding():
		player.get_node("ClimbCollision").position.x = 10;
		is_collision_left = false;
		player.get_node("AnimatedSprite").flip_h = false;
	
	player.set_collision("ClimbCollision");
	
	player.velocity.x *= 2;

func move(delta):
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func move_x(move_mod: int, collision_left: bool) -> void:
	if (collision_left == true and player.is_left_raycast_colliding()) or (collision_left == false and player.is_right_raycast_colliding()):
		player.velocity.x += player.move_acceleration * move_mod * 10;
		#player.velocity.x *= 2;
		
		if Input.is_action_pressed("slide"):
			player.velocity.y = player.climb_speed;
		elif player.velocity.y > -player.climb_speed:
			player.velocity.y = -player.climb_speed;
	elif player.is_on_floor():
		player.set_movement_state("running");
	else:
		player.set_movement_state("falling");
	
	if Input.is_action_just_pressed("jump"):
		if not player.is_top_raycast_colliding():
			player.velocity.x -= player.jump_speed / 5 * move_mod;
			player.velocity.y -= player.jump_speed / 3;
		else:
			player.velocity.x -= player.jump_speed / 2 * move_mod;
			player.velocity.y -= player.jump_speed / 2;
		player.set_movement_state("falling");

func get_input():
	player.velocity.y += player.gravity / 6;
	
	if Input.is_action_pressed("move_left"):
		move_x(-1, is_collision_left);
		if not player.is_left_raycast_colliding():
			player.set_movement_state("falling");
	elif Input.is_action_pressed("move_right"):
		move_x(1, is_collision_left);
		if not player.is_right_raycast_colliding():
			player.set_movement_state("falling");
	elif player.is_on_floor():
		player.set_movement_state("idle");
	elif player.velocity.y < 0:
		player.velocity.y += player.air_acceleration;
	elif player.is_in_air():
		player.set_movement_state("falling");
	
	if Input.is_action_just_pressed("railgun"):
		player.velocity = (player.get_global_mouse_position() - player.position).normalized() * player.railgun_speed;
		player.set_movement_state("railgun");

func get_collisions():
	pass;
