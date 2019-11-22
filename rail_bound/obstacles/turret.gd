extends StaticBody2D

var is_tracking_player := false;
var player;

func _ready() -> void:
	$ShootTimer.connect("timeout", self, "on_shoot_timeout");
	player = get_parent().get_node("Player");

func _physics_process(delta: float) -> void:
	if $Barrel.get_angle_to(player.position) > rotation:
		$Barrel.rotation += .01;
	else:
		$Barrel.rotation -= .01;

func on_shoot_timeout():
	$RayCast2D.cast_to = (player.position - position);
	$RayCast2D.force_raycast_update();
	
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider().name == "Player":
			var bullet = load("res://projectiles/Bullet.tscn").instance();
			get_parent().add_child(bullet);
			bullet.rotation = $Barrel.rotation;
			bullet.position = position + Vector2(cos($Barrel.rotation), sin($Barrel.rotation)) * 60;
			bullet.velocity = Vector2(cos($Barrel.rotation), sin($Barrel.rotation)) * 100;