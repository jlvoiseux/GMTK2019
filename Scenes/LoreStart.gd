extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func _process(delta):
	if (Input.is_action_just_pressed("ui_select")):
		get_tree().change_scene("res://Scenes/Main.tscn")
