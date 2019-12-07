extends Node2D

var bottom_tile_y = 12;
var top_tile_y = -9;

var entry_tile := Vector2(4, 13);
var exit_tile := Vector2(4, 13);

func _ready() -> void:
	$Exit.connect("body_entered", self, "on_exit_entered");
	
	generate_chunk();
	$Exit.position.x = exit_tile.x * 50 + 25;
	$Exit.position.y = exit_tile.y * 50 + 75;
	generate_chunk();
	#generate_chunk();

func generate_random_obstacle(origin_x, pos_y, cast_x, bounds):
	if cast_x < 0:
		$RayCast2D.position = Vector2(origin_x - 1, pos_y) * 50 + Vector2(0, 25);
	else:
		$RayCast2D.position = Vector2(origin_x + 2, pos_y) * 50 + Vector2(0, 25);
	$RayCast2D.cast_to = Vector2(cast_x, 0);#-500
	$RayCast2D.force_raycast_update();
	#var left_bounds: = -10;
	
	if $RayCast2D.is_colliding():
		var point = $RayCast2D.get_collision_point();
		var result = point.x - $RayCast2D.global_position.x;
		bounds = result / 50;
		print("bounds: ", bounds);
	
	print("bounds: ", bounds);
	if bounds < 0:
		var pos_x = 50 * (origin_x - 1) - (randi() % int(abs(bounds))) * 50 - 20;
		
		var obstacle = load("res://obstacles/Turret.tscn").instance();
		$Obstacles.add_child(obstacle);
		obstacle.position = Vector2(pos_x, pos_y * 50 + 25);
	elif bounds > 0:
		var pos_x = 50 * (origin_x + 2) + (randi() % int(bounds)) * 50 + 20;
		
		var obstacle = load("res://obstacles/Turret.tscn").instance();
		$Obstacles.add_child(obstacle);
		obstacle.position = Vector2(pos_x, pos_y * 50 + 25);

func generate_chunk():
	entry_tile = exit_tile;
	
	randomize();
	exit_tile.x = randi() % 20 + 2;
	exit_tile.y = entry_tile.y - 25;
	
	#generate walls
	for k in range(exit_tile.y, entry_tile.y + 2):
		$TileMap.set_cell(0, k, 0);
		$TileMap.set_cell(23, k, 0);
	
	for i in range(1, 23):
		$TileMap.set_cell(i, exit_tile.y, 0);
		$TileMap.set_cell(i, exit_tile.y + 1, 0);
		$TileMap.set_cell(i, exit_tile.y + 2, 0);
	
	#make exit
	for k in [0, 1, 2]:
		for i in [-1, 0, 1]:
			print("tile: x: ", exit_tile.x + i, " y: ", exit_tile.y + k);
			$TileMap.set_cell(exit_tile.x + i, exit_tile.y + k, -1);
	
	#generate platforms
	var n = randi() % 2 + 1;
	while n <= 22:
		var increment;
		if randi() % 2 == 0:
			increment = 1;
		else:
			increment = -1;
		
		var tile = Vector2(0, 0);
		tile.x = randi() % 21 + 1;
		tile.y = entry_tile.y - n;
		
		var length = randi() % 8 + 3;
		var height = randi() % 3 + 1;
		
		for k in height:
			for i in length:
				var x = tile.x + i * increment;
				var y = tile.y + k;
				
				
				$TileMap.set_cell(tile.x + i * increment, tile.y + k, 0);
		
		n += randi() % 3 + 1;
	
	#generate path to exit
	var lower_mid_point = entry_tile;
	lower_mid_point.y -= 11;
	
	var upper_mid_point = exit_tile;
	upper_mid_point.y += 15;
	
	print("points");
	print(entry_tile);
	print(lower_mid_point);
	print(upper_mid_point);
	print(exit_tile);
	print('\n');
	
	for k in range(lower_mid_point.y, entry_tile.y + 3):
		for i in [-1, 0, 1]:
			$TileMap.set_cell(entry_tile.x + i, k, 1);
	
	$TileMap.update_dirty_quadrants();
	
	for k in range(lower_mid_point.y, entry_tile.y):
		if randi() % 2 == 0:
			generate_random_obstacle(entry_tile.x, k, -500, -10);
		if randi() % 2 == 0:
			generate_random_obstacle(entry_tile.x, k, 500, 10);
	
	for k in [-1, 0, 1]:
		if lower_mid_point.x < upper_mid_point.x:
			for i in range(lower_mid_point.x - 1, upper_mid_point.x + 2):
				$TileMap.set_cell(i, lower_mid_point.y + k, 1);
		else:
			for i in range(upper_mid_point.x - 1, lower_mid_point.x + 2):
				$TileMap.set_cell(i, lower_mid_point.y + k, 1);
	
	for k in range(exit_tile.y, upper_mid_point.y):
		for i in [-1, 0, 1]:
			$TileMap.set_cell(exit_tile.x + i, k, 1);
	
	for k in range(exit_tile.y, upper_mid_point.y - 2):
		if randi() % 2 == 0:
			generate_random_obstacle(exit_tile.x, k, -500, -10);
		if randi() % 2 == 0:
			generate_random_obstacle(exit_tile.x, k, 500, 10);
	
	$TileMap.update_bitmask_region();

func on_exit_entered(body):
	if body.name == "Player":
		$Exit.position.x = exit_tile.x * 50 + 25;
		$Exit.position.y = exit_tile.y * 50 + 75;
		generate_chunk();