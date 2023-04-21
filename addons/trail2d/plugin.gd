@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Trail2D","Line2D",preload("res://addons/trail2d/trail_2d.gd"),preload("res://addons/trail2d/trail2d_icon.svg"))
	pass

func _exit_tree():
	remove_custom_type("Trail2D")
	pass
