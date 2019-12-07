extends Obstacle

var player;

func _ready() -> void:
	$ShootTimer.connect("timeout", self, "on_shoot_timeout");
	player = get_node("/root/Level/Player");

func _physics_process(delta: float) -> void:
	$RayCast2D.cast_to = (player.position - position);
	$RayCast2D.force_raycast_update();
	
	if is_player_visible($RayCast2D):
		$Launcher.frame = 1;
	else:
		$Launcher.frame = 0;

func on_shoot_timeout():
	if is_player_visible($RayCast2D):
		var missile = load("res://projectiles/Missile.tscn").instance();
		add_child(missile);