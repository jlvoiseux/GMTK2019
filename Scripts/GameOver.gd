extends Node2D

var score
var gameOverTimer
var gameOverInitialWait = 1
var gameOverInterval = 0.5
var displayCount = 0

var moves
var movesSprite
var movesWordSprite

var misses
var missesSprite
var missesWordSprite

var kills
var killsSprite
var killsWordSprite

var finalScore
var finalScoreSprite
var finalScoreWordSprite

var readTheBook
var bookObtained
var noBook

var arrow
var arrow_pos = 1
var bookFlag = false
var bookThreshold = 500
var menu
var retry
var tap
var tapMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	
	score = get_node("/root/ScoreManagement")
	
	tap = get_node("tap")
	tapMenu = get_node("tapMenu")
	movesWordSprite = get_node("Moves")
	movesSprite = get_node("MovesNum")
	movesWordSprite.visible = false
	movesSprite.visible = false
	
	missesWordSprite = get_node("Miss")
	missesSprite = get_node("MissNum")
	missesWordSprite.visible = false
	missesSprite.visible = false
	
	killsWordSprite = get_node("Kills")
	killsSprite = get_node("KillsNum")
	killsWordSprite.visible = false
	killsSprite.visible = false
	
	finalScoreWordSprite = get_node("FinalScore")
	finalScoreSprite = get_node("FinalScoreNum")
	finalScoreWordSprite.visible = false
	finalScoreSprite.visible = false	
	
	menu = get_node("Menu")
	retry = get_node("Retry")
	readTheBook = get_node("Book")
	bookObtained = get_node("BookObtained")
	noBook = get_node("NoBook")
	readTheBook.visible = false
	bookObtained.visible = false
	noBook.visible = false
	menu.visible = false
	retry.visible = false	
	
	moves = score.moves
	misses = score.misses
	kills = score.kills
	finalScore = max(0, 100*kills - 2*moves - 20*misses)
	#finalScore = 500
	
	movesSprite.setCounter(moves)
	missesSprite.setCounter(misses)
	killsSprite.setCounter(kills)
	finalScoreSprite.setCounter(finalScore)
	if(finalScore >= bookThreshold):
		bookFlag = true
	
	gameOverTimer = Timer.new()
	gameOverTimer.connect("timeout",self,"displayScores") 
	add_child(gameOverTimer) #to process
	gameOverTimer.set_wait_time(gameOverInterval)
	gameOverTimer.set_one_shot(false)
	gameOverTimer.start() #to start
	
	arrow = get_node("menu_arrow")
	arrow.position.x = 6
	arrow.position.y = 136
	arrow.visible = false
	set_process(true)
	
func _process(delta):
	if(bookFlag):
		if Input.is_action_just_pressed("ui_left") && arrow_pos > 0:
			tapMenu.play()
			arrow_pos -= 1
		elif Input.is_action_just_pressed("ui_right") && arrow_pos < 2:
			tapMenu.play()
			arrow_pos += 1		
		if (arrow_pos == 0 && Input.is_action_just_pressed("ui_select")):
			tapMenu.play()
			get_tree().change_scene("res://Scenes/Menu.tscn")
		elif (arrow_pos == 1 && Input.is_action_just_pressed("ui_select")):
			tapMenu.play()
			get_tree().change_scene("res://Scenes/Main.tscn")
		elif (arrow_pos == 2 && Input.is_action_just_pressed("ui_select") && bookFlag):
			tapMenu.play()
			get_tree().change_scene("res://Scenes/LoreEnd.tscn")
	else:
		if Input.is_action_just_pressed("ui_left") && arrow_pos > 0:
			tapMenu.play()
			arrow_pos -= 1
		elif Input.is_action_just_pressed("ui_right") && arrow_pos < 1:
			tapMenu.play()
			arrow_pos += 1		
		if (arrow_pos == 0 && Input.is_action_just_pressed("ui_select")):
			tapMenu.play()
			get_tree().change_scene("res://Scenes/Menu.tscn")
		elif (arrow_pos == 1 && Input.is_action_just_pressed("ui_select")):
			tapMenu.play()
			get_tree().change_scene("res://Scenes/Main.tscn")
			
	if(arrow_pos == 0):
		arrow.position.x = 6
		arrow.position.y = 136
	elif(arrow_pos == 1):
		arrow.position.x = 73
		arrow.position.y = 136
	elif(arrow_pos == 2 && bookFlag):
		arrow.position.x = 147
		arrow.position.y = 136

func displayScores():
	
	if displayCount == 0:
		tap.play()
		killsWordSprite.visible = true
		killsSprite.visible = true		
	elif displayCount == 1:
		tap.play()
		movesWordSprite.visible = true
		movesSprite.visible = true
	elif displayCount == 2:
		tap.play()
		missesWordSprite.visible = true
		missesSprite.visible = true
	elif displayCount == 3:
		tap.play()
		finalScoreWordSprite.visible = true
	elif displayCount == 4:
		tap.play()
		finalScoreSprite.visible = true
	elif (displayCount == 5 && !bookFlag):
		tap.play()
		noBook.visible = true
	elif (displayCount == 5 && bookFlag):
		tap.play()
		bookObtained.visible = true
	elif (displayCount == 6 && !bookFlag):
		tap.play()
		menu.visible = true
		arrow.visible = true
		retry.visible = true
	elif (displayCount == 6 && bookFlag):
		tap.play()
		menu.visible = true
		arrow.visible = true
		retry.visible = true
		readTheBook.visible = true		
	displayCount += 1
		
