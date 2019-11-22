extends StaticBody2D

export var speed := 1;

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	rotation += speed * delta;
