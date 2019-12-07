extends Obstacle

var is_tracking_player := false;
var is_shooting := false;
var player;

func _ready() -> void:
	$ShootTimer.connect("timeout", self, "on_shoot_timeout");
	$CooldownTimer.connect("timeout", self, "on_cooldown_timeout");
	
	player = get_node("/root/Level/Player");
	$Barrel/RayCast2D.add_exception(self);

func _physics_process(delta: float) -> void:
	if not is_shooting:
		$RayCast2D.cast_to = (player.position - position);
		$RayCast2D.force_raycast_update();
		
		if is_player_visible($RayCast2D):
			if $Barrel.get_angle_to(player.position) > rotation:
				$Barrel.rotation += .01;
			else:
				$Barrel.rotation -= .01;
			
			$Barrel/RayCast2D.force_raycast_update();
			if is_player_visible($Barrel/RayCast2D):
				is_shooting = true;
				$ShootTimer.start();

func on_shoot_timeout():
	$Barrel/Line2D.points[1] = $Barrel/RayCast2D.cast_to;
	$Barrel/Line2D.show();
	$CooldownTimer.start();

func on_cooldown_timeout():
	$Barrel/Line2D.hide();
	is_shooting = false;