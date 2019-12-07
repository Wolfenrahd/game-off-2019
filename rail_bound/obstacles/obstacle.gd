extends StaticBody2D

class_name Obstacle

func _ready() -> void:
	pass

func is_player_visible(raycast: RayCast2D) -> bool:
	if raycast.is_colliding():
		if raycast.get_collider().name == "Player":
			return true;
	
	return false;