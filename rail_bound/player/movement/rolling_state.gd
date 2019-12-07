extends MovementState

class_name RollingState

func _init(player_ref).(player_ref):
	player.set_animation("railgun");
	player.set_collision("RailgunCollision");

func move(delta):
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func get_input():
	player.velocity.y += player.gravity;
	
	if Input.is_action_pressed("move_left"):
		player.velocity.x = -player.move_speed;
	elif Input.is_action_pressed("move_right"):
		player.velocity.x = player.move_speed;
	else:
		player.velocity.x = 0;
	
	if not player.get_node("LeftRayCast1").is_colliding() and not player.get_node("RightRayCast1").is_colliding():
		player.set_movement_state("running");

func get_collisions():
	pass;