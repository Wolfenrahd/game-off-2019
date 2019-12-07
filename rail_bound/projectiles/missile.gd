extends Area2D

var speed := 100.0;

var player;

func _ready() -> void:
	player = get_node("/root/Level/Player");
	connect("body_entered", self, "on_body_entered");

func _physics_process(delta: float) -> void:
	var angle = get_angle_to(player.position);
	
	if angle > 0:
		rotation += .02;
	else:
		rotation -= .02;
	
	position += Vector2(cos(rotation), sin(rotation)) * speed * delta;

func on_body_entered(body) -> void:
	if body.name == "Player":
		queue_free();
		body.obstacle_hit();
	else:
		queue_free();