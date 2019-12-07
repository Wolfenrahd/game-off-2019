extends Area2D

export var speed := 1;

var is_up := false;

func _ready() -> void:
	$Timer.connect("timeout", self, "on_timeout");
	connect("body_entered", self, "on_body_entered");

func on_timeout():
	if is_up:
		$Tween.interpolate_property(self, "position:y", position.y, position.y - 50, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	else:
		$Tween.interpolate_property(self, "position:y", position.y, position.y + 50, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	$Tween.start();
	
	is_up = !is_up;

func on_body_entered(body):
	if body.name == "Player":
		body.obstacle_hit();