extends Node2D

var arrow
var arrow_pos = 0
var tapMenu
# Called when the node enters the scene tree for the first time.
func _ready():
	tapMenu = get_node("tapMenu")
	arrow = get_node("menu_arrow")
	arrow.position.x = 31.354
	arrow.position.y = 113.94
	set_process(true)
	
func _process(delta):
	
	if Input.is_action_just_pressed("ui_left"):
		tapMenu.play()
		arrow.position.x = 31.354
		arrow.position.y = 113.94
		arrow_pos = 0
	elif Input.is_action_just_pressed("ui_right"):
		tapMenu.play()
		arrow.position.x = 149.444
		arrow.position.y = 113.94
		arrow_pos = 1
	
	if (arrow_pos == 0 && Input.is_action_just_pressed("ui_select")):
		tapMenu.play()
		get_tree().change_scene("res://Scenes/LoreStart.tscn")
	elif (arrow_pos == 1 && Input.is_action_just_pressed("ui_select")):
		tapMenu.play()
		get_tree().change_scene("res://Scenes/Credits.tscn")
