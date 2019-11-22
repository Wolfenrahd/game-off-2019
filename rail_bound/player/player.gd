extends KinematicBody2D

export var gravity := 9.8;
var velocity = Vector2(0, 0);
export var move_speed := 50.0;
export var jump_speed := 300.0;
export var railgun_speed := 300.0;

export var move_acceleration := 1.0;
export var air_acceleration := 2.0;

var is_collision_left := false;
var is_railgun := false;

func _ready() -> void:
	pass

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

func _physics_process(delta: float) -> void:
	get_collision_direction();
	
	print("railgun: ", is_railgun);
	
	if Input.is_action_pressed("move_left"):
		if is_on_floor():
			if velocity.x > -move_speed:
				velocity.x = -move_speed;
			velocity.x -= move_acceleration;
			set_animation("running");
		else:
			velocity.x -= air_acceleration;
	elif Input.is_action_pressed("move_right"):
		if is_on_floor():
			if velocity.x < move_speed:
				velocity.x = move_speed;
			velocity.x += move_acceleration;
			set_animation("running");
		else:
			velocity.x += air_acceleration;
	elif is_on_floor():
		velocity.x = 0;
		is_railgun = false;
		set_animation("idle");
	elif velocity.y <= 0:
		set_animation("jumping");
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump_speed;
	elif Input.is_action_just_pressed("jump") and is_on_wall():
		if is_collision_left:
			velocity.x += move_speed;
			velocity.y -= jump_speed;
		else:
			velocity.x -= move_speed;
			velocity.y -= jump_speed;
	
	if Input.is_action_just_pressed("railgun") and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		velocity = (get_global_mouse_position() - position).normalized() * railgun_speed;
		is_railgun = true;
	
	if is_in_air():
		if is_railgun:
			set_animation("railgun");
		elif velocity.y <= 0:
			set_animation("jumping");
		else:
			set_animation("falling");
	
	if not is_on_wall():
		velocity.y += gravity;
	elif not is_railgun:
		velocity.y += gravity / 5;# = 0
		if velocity.y < 0:
			set_animation("climbing_up");
		else:
			set_animation("climbing_down");
	
	if velocity.x < 0:
		$AnimatedSprite.flip_h = true;
	elif velocity.x > 0:
		$AnimatedSprite.flip_h = false;
	
	var new_velocity = move_and_slide(velocity, Vector2(0, -1));
	if not((is_on_wall() or is_on_ceiling()) and is_railgun):
		velocity = new_velocity;
	elif is_railgun:
		velocity.x /= 2.0;
		if velocity.y < 0:
			velocity.y /= 2.5;
		
		print("REBOUND! Length: ", velocity.length());
		if velocity.length() <= 500:
			is_railgun = false;
		if is_on_wall():
			velocity.x *= -1;
			#is_railgun = false;
		elif is_on_ceiling():
			print("on ceiling");
			#is_railgun = false;
			velocity.y *= -1;