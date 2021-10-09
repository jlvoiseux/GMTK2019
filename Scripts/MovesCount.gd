extends Node2D

var s_10000
var s_1000
var s_100
var s_10
var s_1

var v_10000
var v_1000
var v_100
var v_10
var v_1

# Called when the node enters the scene tree for the first time.
func _ready():
	s_10000 = get_node("AnimatedSprite")
	s_1000 = get_node("AnimatedSprite2")
	s_100 = get_node("AnimatedSprite3")
	s_10 = get_node("AnimatedSprite4")
	s_1 = get_node("AnimatedSprite5")
	
func setCounter(value):
	
	var valStr = String(value)
	if valStr.length() == 1:
		s_1.set_frame(int(valStr[0]))
	if valStr.length() == 2:
		s_10.set_frame(int(valStr[0]))
		s_1.set_frame(int(valStr[1]))
	if valStr.length() == 3:
		s_100.set_frame(int(valStr[0]))
		s_10.set_frame(int(valStr[1]))
		s_1.set_frame(int(valStr[2]))
	if valStr.length()== 4:
		s_1000.set_frame(int(valStr[0]))
		s_100.set_frame(int(valStr[1]))
		s_10.set_frame(int(valStr[2]))
		s_1.set_frame(int(valStr[3]))
	if valStr.length() == 5:
		s_10000.set_frame(int(valStr[1]))
		s_1000.set_frame(int(valStr[2]))
		s_100.set_frame(int(valStr[3]))
		s_10.set_frame(int(valStr[4]))
		s_1.set_frame(int(valStr[5]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
