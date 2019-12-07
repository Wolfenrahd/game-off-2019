extends Area2D

export var speed := 1;

func _ready() -> void:
	connect("body_entered", self, "on_body_entered");

func _physics_process(delta: float) -> void:
	rotation += speed * delta;

func on_body_entered(body):
	if body.name == "Player":
		body.obstacle_hit();