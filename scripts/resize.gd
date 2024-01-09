extends Node

# Declare the variable
var sub_viewport: Viewport

func _ready():
	# Initialize the sub_viewport variable
	sub_viewport = $SubViewportContainer as Viewport
	
	# Connect the resize event using the new Callable syntax
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))

func _on_viewport_size_changed():
	var new_size = get_viewport().size
	sub_viewport.size = new_size
