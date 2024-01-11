extends Node3D

@export var threshold_distance: int = 400
var is_loaded: bool = false
var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Ps1PostProcess/SubViewportContainer/SubViewport/world/player") 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player < threshold_distance and not is_loaded:
		load_zone()
	elif distance_to_player >= threshold_distance and is_loaded:
		unload_zone()

func unload_zone():
	hide()  # Hide the top-level node
	for child in get_children():
		recursive_hide_and_pause(child)
	is_loaded = false

func recursive_hide_and_pause(node):
	node.hide()
	if node is Node3D:  
		node.process_mode = Node.PROCESS_MODE_DISABLED
		for child in node.get_children():
			recursive_hide_and_pause(child)

func load_zone():
	show()  # Show the top-level node
	for child in get_children():
		recursive_show_and_unpause(child)
	is_loaded = true

func recursive_show_and_unpause(node):
	node.show()
	if node is Node3D:
		node.process_mode = Node.PROCESS_MODE_INHERIT 
		for child in node.get_children():
			recursive_show_and_unpause(child)

