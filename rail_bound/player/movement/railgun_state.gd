extends MovementState

class_name RailgunState

var last_velocity := Vector2(0, 0);

func _init(player_ref).(player_ref):
	player.set_animation("railgun");
	player.set_collision("RailgunCollision");

func move(delta):
	last_velocity = player.velocity;
	player.velocity = player.move_and_slide(player.velocity, Vector2(0, -1));

func get_input():
	player.velocity.y += player.gravity;
	
	if Input.is_action_pressed("move_left"):
		player.velocity.x -= player.air_acceleration;
	elif Input.is_action_pressed("move_right"):
		player.velocity.x += player.air_acceleration;
	
	if player.is_on_wall():
		player.velocity.x = last_velocity.x * -0.5;
	if player.is_on_ceiling():
		player.velocity.y = last_velocity.y * -0.5;
	
	if player.velocity.length() <= 500 or player.is_on_floor():
		if player.get_node("CeilingRayCast").is_colliding() and player.get_node("GroundRayCast").is_colliding():
			player.set_movement_state("rolling");
		elif not player.is_on_ceiling():
			player.set_movement_state("falling");
			if player.get_node("GroundRayCast").is_colliding():
				player.position.y -= 40;
		elif player.is_on_floor():
			player.set_movement_state("running");
			if player.get_node("GroundRayCast").is_colliding():
				player.position.y -= 40;

func get_collisions():
	pass;