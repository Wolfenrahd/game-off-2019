extends MovementState

class_name IdleState

func _init(player_ref).(player_ref) -> void:
	player.velocity.x = 0;
	if Input.is_action_pressed("slide"):
		player.set_animation("sliding");
		player.set_collision("SlideCollision");
	else:
		player.set_animation("idle");
		player.set_collision("IdleCollision");

func move(delta):
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func get_input():
	player.velocity.y += player.gravity;
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		player.set_movement_state("running");
	elif Input.is_action_just_pressed("jump"):
		player.velocity.y -= player.jump_speed;
		player.set_movement_state("falling");
	
	if Input.is_action_just_pressed("slide"):
		player.set_animation("sliding");
		player.set_collision("SlideCollision");
	elif Input.is_action_just_released("slide"):
		player.set_animation("idle");
		player.set_collision("IdleCollision");
	
	if Input.is_action_just_pressed("railgun"):
		player.velocity = (player.get_global_mouse_position() - player.position).normalized() * player.railgun_speed;
		player.set_movement_state("railgun");
	

func get_collisions():
	if not player.is_on_floor():
		player.set_movement_state("falling");