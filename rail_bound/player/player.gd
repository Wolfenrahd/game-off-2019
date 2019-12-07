extends KinematicBody2D

export var gravity := 9.8;
var velocity = Vector2(0, 0);
export var move_speed := 50.0;
export var jump_speed := 300.0;
export var railgun_speed := 300.0;
export var climb_speed := 50.0;
export var slide_boost := 50.0;

export var move_acceleration := 1.0;
export var air_acceleration := 2.0;

var is_collision_left := false;
var is_railgun := false;
var is_crawling := false;

var MOVEMENT_STATE = {};
var movement_state;


func _ready() -> void:
	$HitTimer.connect("timeout", self, "on_hit_timeout");
	
	MOVEMENT_STATE["idle"] = preload("res://player/movement/idle_state.gd");
	MOVEMENT_STATE["running"] = preload("res://player/movement/running_state.gd");
	MOVEMENT_STATE["falling"] = preload("res://player/movement/falling_state.gd");
	MOVEMENT_STATE["climbing"] = preload("res://player/movement/climbing_state.gd");
	MOVEMENT_STATE["rolling"] = preload("res://player/movement/rolling_state.gd");
	MOVEMENT_STATE["railgun"] = preload("res://player/movement/railgun_state.gd");
	
	movement_state = MOVEMENT_STATE["idle"].new(self);

func set_movement_state(state):
	movement_state = MOVEMENT_STATE[state].new(self);

func get_collision_direction():
	if get_slide_count() > 0:
		var i = get_slide_count() - 1;
		var collision = get_slide_collision(i);
		if collision.position < position:
			is_collision_left = true;
		else:
			is_collision_left = false;

func set_animation(anim):
	if $AnimatedSprite.animation != anim:
		$AnimatedSprite.animation = anim;

func is_in_air() -> bool:
	if not (is_on_floor() or is_on_wall() or is_on_ceiling()):
		return true;
	else:
		return false;

func set_collision(name: String) -> void:
	get_node(name).disabled = false;
	get_node(name).visible = true;
	
	for collision in get_tree().get_nodes_in_group("player_collision"):
		if collision.name != name:
			collision.disabled = true;
			collision.visible = false;

func is_raycast_colliding() -> bool:
	if is_left_raycast_colliding() or is_right_raycast_colliding():
		return true;
	return false;

func is_left_raycast_colliding() -> bool:
	if $LeftRayCast1.is_colliding() or $LeftRayCast2.is_colliding() or $LeftRayCast3.is_colliding():
		return true;
	return false;

func is_right_raycast_colliding() -> bool:
	if $RightRayCast1.is_colliding() or $RightRayCast2.is_colliding() or $RightRayCast3.is_colliding():
		return true;
	return false;

func is_top_raycast_colliding() -> bool:
	if $RightRayCast1.is_colliding() or $LeftRayCast1.is_colliding():
		return true;
	return false;

func start_sliding(affect_velocity: bool) -> void:
	set_animation("sliding");
	set_collision("SlideCollision");
	
	if affect_velocity:
		if velocity.x > 0:
			velocity.x += slide_boost;
		elif velocity.x < 0:
			velocity.x -= slide_boost;

func slide_velocity():
	if Input.is_action_pressed("slide"):
		velocity.x -= move_acceleration;

func slide_x(move_direction: int) -> void:
	set_animation("slide");
	set_collision("SlideCollision");
	
	velocity.x += move_acceleration * move_direction;
	if velocity.x * move_direction > 0:
		velocity.x = 0;

func move_x(move_direction: int) -> void:
	if is_on_floor():
		if Input.is_action_pressed("slide"):
			slide_x(move_direction);
		else:
			if velocity.x * move_direction > -move_speed:
				velocity.x = -move_speed * move_direction;
			velocity.x -= move_acceleration * move_direction;
			set_animation("running");
			set_collision("IdleCollision");
	else:
		velocity.x -= air_acceleration * move_direction;
	
	$ClimbCollision.position.x = -10 * move_direction;

func _input(event: InputEvent) -> void:
	if Global.debug_mode:
		if event is InputEventMouseButton and event.is_pressed():
			position = get_global_mouse_position();
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_0:
			position.y -= 40;
			set_collision("IdleCollision");
		if event.scancode == KEY_1:
			Global.debug_mode = !Global.debug_mode;
		if event.scancode == KEY_9:
			set_animation("idle");
		if event.scancode == KEY_8:
			set_collision("RailgunCollision");

func get_input() -> void:
	if Input.is_action_pressed("move_left"):
		move_x(1);
	elif Input.is_action_pressed("move_right"):
		move_x(-1);
	elif is_on_floor():
		velocity.x = 0;
		set_animation("idle");
	elif velocity.y <= 0:
		set_animation("jumping");
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_speed;
	elif Input.is_action_just_pressed("jump") and is_on_wall():
		if is_collision_left:
			velocity.x += move_speed;
			velocity.y -= jump_speed / 2;
		else:
			velocity.x -= move_speed;
			velocity.y -= jump_speed / 2;
	
	if Input.is_action_just_pressed("railgun") and not is_in_air():
		velocity = (get_global_mouse_position() - position).normalized() * railgun_speed;
		is_railgun = true;
		set_collision("RailgunCollision");

func move() -> void:
	var new_velocity = move_and_slide(velocity, Vector2(0, -1));
	
	if is_railgun and (is_on_wall() or is_on_ceiling()):
		velocity.x /= 2.0;
		
		if velocity.y < 0:
			velocity.y /= 2.5;
		
		if velocity.length() <= 500:
			is_railgun = false;
			set_collision("IdleCollision");
		
		if is_on_wall():
			velocity.x *= -1;
		elif is_on_ceiling():
			velocity.y *= -1;
	elif is_railgun and is_on_floor():
		is_railgun = false;
		set_collision("IdleCollision");
	else:
		velocity = new_velocity;
	#rebound
	

func can_climb():
	if not is_railgun and not ($GroundRayCast.is_colliding() or $CeilingRayCast.is_colliding()):
		return true;
	
	return false;

func _physics_process(delta: float) -> void:
	movement_state.move(delta);
	movement_state.get_input();
	movement_state.get_collisions();
#	get_collision_direction();
#
#	get_input();
#
#	if is_in_air():
#		if is_railgun:
#			set_animation("railgun");
#		elif velocity.y <= 0:
#			set_animation("jumping");
#			set_collision("IdleCollision");
#		else:
#			set_animation("falling");
#			set_collision("IdleCollision");
#
#
#	print("G: ", $GroundRayCast.is_colliding(), " C: ", $CeilingRayCast.is_colliding());
#	if not is_on_wall():
#		velocity.y += gravity;
#		print("not on wall");
#	elif can_climb():
#		velocity.x *= 2;
#		velocity.y += gravity / 6;# = 0
#		if velocity.y < 0:
#			set_animation("climbing_up");
#			set_collision("ClimbCollision");
#		else:
#			set_animation("climbing_down");
#			set_collision("ClimbCollision");
#		print("climbing");
#
#	if not is_railgun and $GroundRayCast.is_colliding():
#		print("ground");
#		position.y -= 40;
#		if $CeilingRayCast.is_colliding():
#			set_animation("climbing_up");
#			set_collision("ClimbCollision");
#			$AnimatedSprite.rotation_degrees = 90;
#			is_crawling = true;
#	elif not is_railgun and $CeilingRayCast.is_colliding():
#		print("ceiling");
#		position.y += 40;
#		if $GroundRayCast.is_colliding():
#			set_animation("climbing_up");
#			set_collision("ClimbCollision");
#			$AnimatedSprite.rotation_degrees = 90;
#			is_crawling = true;
#
##	if not is_railgun:
##		if $CeilingRayCast.is_colliding():
##			position.y += 40;
##			print("Ceiling");
##		elif $GroundRayCast.is_colliding() and $CeilingRayCast.is_colliding():
##			set_animation("railgun");
##			set_collision("RailgunCollision");
##			velocity.y += gravity;
##			print("roll");
##		elif $GroundRayCast.is_colliding():
##			print("ground");#position.y -= 40;


#	if velocity.x < 0:
#		$AnimatedSprite.flip_h = true;
#	elif velocity.x > 0:
#		$AnimatedSprite.flip_h = false;
#
#	move();

func obstacle_hit():
	$Tween.stop_all();
	$Tween.interpolate_property($AnimatedSprite, "modulate.r", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	$Tween.start();
	$HitTimer.start();
	$AnimatedSprite.material.set_shader_param("isHit", true);

func on_hit_timeout():
	$AnimatedSprite.material.set_shader_param("isHit", false);