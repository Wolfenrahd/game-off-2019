extends Area2D

var velocity := Vector2(1.0, 0.0);

func _ready() -> void:
	connect("body_entered", self, "on_body_entered");

func _physics_process(delta: float) -> void:
	position += velocity * delta;

func on_body_entered(body):
	queue_free();
	if body.name == "Player":
		body.obstacle_hit();
