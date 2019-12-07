extends Node

class_name MovementState

var player;

func _init(player_ref):
	player = player_ref;

func move(delta):
	pass;

func get_input():
	pass;

func get_collisions():
	pass;