extends Node2D

var grid

var snakeSpeed = 4.5
var snakeAcc = 4
var speedIncrement = 1
var bulletSpeed = 15
var snakeLimitLeft = 15 #6
var snakeLimitRight = 30 #31
var snakeLimitUp = 8 #0
var snakeLimitDown = 16 #17
var snakeHeadPos = Vector2(17, 12)
var snakeHeadGrid = snakeHeadPos
var snakeGridQueue = [snakeHeadGrid, Vector2(snakeHeadGrid.x, snakeHeadGrid.y-1), Vector2(snakeHeadGrid.x, snakeHeadGrid.y-2)]
var snakeDir = Vector2(1, 0)
var foodEaten = false
var foodEatenFlag = false
var growthRate = 0.1
var foodPos
var targetPos
var distFoodTarget
var distFoodTargetThreshold = 5
var growthTimer
var bulletFired = false
var bulletFlag = false
var bulletPos
var bulletDir
var bulletGrid
var bulletNewGrid
var movesCount = 0
var movesCountSprite
var killsCount = 0
var killsCountSprite
var missesCount = 0
var missesCountSprite
var bulletGone = false
var resetWinX = snakeLimitLeft
var resetWinY = snakeLimitUp
var resetLoseX = snakeLimitLeft
var resetLoseY = snakeLimitUp
var numberOfPosToGenerate = 1000
var foodPosArray = []
var targetPosArray = []
var foodCount = 0
var gameOver = false
var readyToChangeDir = true
var score
var isResetting = false
var moveSound
var fireSound
var pointsSound
var eatSound
var horror

# Called when the node enters the scene tree for the first time.
func _ready():
	score = get_node("/root/ScoreManagement")
	horror = get_node("Horror")
	score.moves = 0
	score.misses = 0
	score.kills = 0
	
	moveSound = get_node("Move")
	fireSound = get_node("Fire")
	pointsSound = get_node("Points")
	eatSound = get_node("Eat")
	
	movesCountSprite = get_node("UI/MovesNum")
	killsCountSprite = get_node("UI/KillsNum")
	missesCountSprite = get_node("UI/MissNum")
	grid = get_node("Grid")
	randomize()
	
	generateFood()	
	generateTarget()
	placeTargetAndFood(true)
	
	set_process(true)
	
	growthTimer = Timer.new()
	growthTimer.connect("timeout",self,"makeSnakeBigger") 
	add_child(growthTimer) #to process
	growthTimer.set_wait_time(growthRate)
	growthTimer.set_one_shot(false)
	growthTimer.start() #to start

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkSnakeHitsItself()
	if(!isResetting):
		checkSnakeHitsTarget()
		if(!bulletGone):
			grid.drawTarget(targetPos.x, targetPos.y, 1)
		if(!foodEaten):
			grid.drawFood(foodPos.x, foodPos.y)	
	if(!gameOver):
		checkSnakeDirection()	
		moveSnake(delta)
		if(!isResetting):
			checkFoodEaten()
		checkBulletFired()
		if(bulletFired):
			moveBullet(delta)
			checkBulletHitTarget()
			checkBulletHitsSnake()
		if(bulletGone && grid.gridReady && resetWinX <= snakeLimitRight && resetWinY <= snakeLimitDown):
			isResetting = true
			resetGridWin(resetWinX , resetWinY)
			if(resetWinX < snakeLimitRight):
				resetWinX += 1
			else:
				resetWinX = snakeLimitLeft
				resetWinY += 1
		elif(bulletGone && grid.gridReady):
			grid.drawTarget(targetPos.x, targetPos.y, 1)
			resetWinX = snakeLimitLeft
			resetWinY = snakeLimitUp
			bulletGone = false
			isResetting = false
	else:
		score.moves = movesCount
		score.misses = missesCount
		score.kills = killsCount
		if(grid.gridReady && resetLoseX <= snakeLimitRight && resetLoseY <= snakeLimitDown):
			resetGridLose(resetLoseX , resetLoseY)
			if(resetLoseX < snakeLimitRight):
				resetLoseX += 1
			else:
				resetLoseX = snakeLimitLeft
				resetLoseY += 1
		elif(grid.gridReady):
			get_tree().change_scene("res://Scenes/GameOver.tscn")
		
func resetGridWin(x, y):
	var caseToBlink = Vector2(x, y)
	if (caseToBlink == foodPos):
		grid.drawFood(x, y)
		grid.oneBlink(x, y, 0, false)		
	elif (caseToBlink == targetPos):
		grid.drawTarget(x, y, 1)
		grid.oneBlink(x, y, 0, false)	
	else:
		grid.oneBlink(x, y, 0, true)
		
func resetGridLose(x, y):
	grid.oneBlink(x, y, 6, true)
		
func checkSnakeHitsItself():
	for i in range(1, snakeGridQueue.size()):
		if snakeHeadGrid == snakeGridQueue[i]:
			grid.getCase(snakeHeadGrid.x, snakeHeadGrid.y).set_frame(3)
			gameOver = true
			
func checkBulletHitsSnake():
	for i in range(1, snakeGridQueue.size()):
		if bulletGrid == snakeGridQueue[i]:
			grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(3)
			gameOver = true
			
func checkSnakeHitsTarget():
	if snakeHeadGrid == targetPos:
			grid.getCase(snakeHeadGrid.x, snakeHeadGrid.y).set_frame(3)
			gameOver = true

func checkBulletFired():
	if(Input.is_action_just_pressed("ui_select") && foodEaten && !bulletFired && !isResetting):
		horror.stop()
		fireSound.play()
		grid.shake()
		bulletFired = true
		bulletDir = snakeDir
		bulletPos = snakeHeadPos+ snakeDir
		bulletGrid = snakeHeadGrid + snakeDir
		

func moveBullet(delta):
	var incrementX = bulletDir.x*delta*bulletSpeed
	var incrementY = bulletDir.y*delta*bulletSpeed
	bulletPos = Vector2(bulletPos.x + incrementX, bulletPos.y + incrementY)
	bulletNewGrid = Vector2(round(bulletPos.x), round(bulletPos.y))
	if(bulletNewGrid.x != bulletGrid.x || bulletNewGrid.y != bulletGrid.y):
		grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
		bulletGrid = bulletNewGrid
		if(bulletGrid.x > snakeLimitRight):
			missesCount += 1
			missesCountSprite.setCounter(missesCount)
			grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
			bulletFired = false
			startReset()
		if(bulletGrid.y > snakeLimitDown):
			missesCount += 1
			missesCountSprite.setCounter(missesCount)
			grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
			bulletFired = false
			startReset()
		if(bulletGrid.x < snakeLimitLeft):
			missesCount += 1
			missesCountSprite.setCounter(missesCount)
			grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
			bulletFired = false
			startReset()
		if(bulletGrid.y < snakeLimitUp):
			missesCount += 1
			missesCountSprite.setCounter(missesCount)
			grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
			bulletFired = false
			startReset()
			
	if bulletFired:
		grid.drawBullet(bulletGrid.x, bulletGrid.y)

func startReset():
	bulletGone = true
	foodEaten = false
	snakeGridQueue = [snakeGridQueue[0], snakeGridQueue[1], snakeGridQueue[2]]	
	placeTargetAndFood(false)

func checkBulletHitTarget():
	if(bulletGrid == targetPos):
		pointsSound.play()
		grid.getCase(bulletGrid.x, bulletGrid.y).set_frame(0)
		bulletFired = false
		killsCount += 1
		killsCountSprite.setCounter(killsCount)
		startReset()
	
func generateFood():	
	for i in range(numberOfPosToGenerate):
		foodPos = Vector2(round(rand_range(snakeLimitLeft, snakeLimitRight)), round(rand_range(snakeLimitUp, snakeLimitDown)))
		foodPosArray.append(foodPos)
		
func generateTarget():
	for i in range(numberOfPosToGenerate):
		targetPos = Vector2(round(rand_range(snakeLimitLeft, snakeLimitRight)), round(rand_range(snakeLimitUp, snakeLimitDown)))
		distFoodTarget = targetPos.distance_to(foodPosArray[i])
		while(distFoodTarget < distFoodTargetThreshold):
			targetPos = Vector2(round(rand_range(snakeLimitLeft, snakeLimitRight)), round(rand_range(snakeLimitUp, snakeLimitDown)))
			distFoodTarget = targetPos.distance_to(foodPosArray[i])
		targetPosArray.append(targetPos)
		
func placeTargetAndFood(draw):
	foodPos = foodPosArray[foodCount]	
	targetPos = targetPosArray[foodCount]	
	while(foodPos == snakeGridQueue[0] || foodPos == snakeGridQueue[1] || foodPos == snakeGridQueue[2] || targetPos == snakeGridQueue[0] || targetPos == snakeGridQueue[1] || targetPos == snakeGridQueue[2] ):
		foodCount += 1
		foodPos = foodPosArray[foodCount]
		targetPos = targetPosArray[foodCount]
	foodPosArray.remove(foodCount)
	targetPosArray.remove(foodCount)
	if draw:		
		grid.drawFood(foodPos.x, foodPos.y)
		grid.drawTarget(targetPos.x, targetPos.y, 1)

func checkFoodEaten():
	if snakeHeadGrid == foodPos && foodEaten == false :
		eatSound.play()
		horror.play()
		foodEaten = true
		
func makeSnakeBigger():
	if(foodEaten):
		snakeGridQueue.insert(1, snakeGridQueue[1])

func checkSnakeDirection():
	if Input.is_action_just_pressed("ui_left") && snakeDir != Vector2(1, 0) && snakeDir != Vector2(-1, 0) && readyToChangeDir:
		snakeDir = Vector2(-1, 0)
		movesCount+=1
		movesCountSprite.setCounter(movesCount)
		readyToChangeDir = false
	elif Input.is_action_just_pressed("ui_right") && snakeDir != Vector2(1, 0) && snakeDir != Vector2(-1, 0) && readyToChangeDir:
		snakeDir = Vector2(1, 0)
		movesCount+=1
		movesCountSprite.setCounter(movesCount)
		readyToChangeDir = false
	elif Input.is_action_just_pressed("ui_down") && snakeDir != Vector2(0, -1) && snakeDir != Vector2(0, 1) && readyToChangeDir:
		snakeDir = Vector2(0, 1)
		movesCount+=1
		movesCountSprite.setCounter(movesCount)
		readyToChangeDir = false
	elif Input.is_action_just_pressed("ui_up") && snakeDir != Vector2(0, 1) && snakeDir != Vector2(0, -1) && readyToChangeDir:
		snakeDir = Vector2(0, -1)
		movesCount+=1
		movesCountSprite.setCounter(movesCount)
		readyToChangeDir = false

func moveSnake(delta):
	var incrementX 
	var incrementY 
	if(foodEaten && !bulletFired):
		incrementX = snakeDir.x*delta*(snakeSpeed+snakeAcc)
		incrementY = snakeDir.y*delta*(snakeSpeed+snakeAcc)
	else:
		incrementX = snakeDir.x*delta*snakeSpeed
		incrementY = snakeDir.y*delta*snakeSpeed
	if(snakeDir.x > 0):
		incrementX = min(1, incrementX)
	if(snakeDir.x < 0):
		incrementX = max(-1, incrementX)
	if(snakeDir.y > 0):
		incrementY = min(1, incrementY)
	if(snakeDir.y < 0):
		incrementY = max(-1, incrementY)
	snakeHeadPos = Vector2(snakeHeadPos.x + incrementX, snakeHeadPos.y + incrementY)
	snakeHeadGrid = Vector2(round(snakeHeadPos.x), round(snakeHeadPos.y))

	if(snakeHeadGrid.x != snakeGridQueue[0].x || snakeHeadGrid.y != snakeGridQueue[0].y):
		moveSound.play()
		if(snakeHeadGrid.x > snakeLimitRight):
			snakeHeadPos.x = snakeLimitLeft
			snakeHeadGrid.x = snakeLimitLeft
		if(snakeHeadGrid.y > snakeLimitDown):
			snakeHeadPos.y = snakeLimitUp
			snakeHeadGrid.y = snakeLimitUp
		if(snakeHeadGrid.x < snakeLimitLeft):
			snakeHeadPos.x = snakeLimitRight
			snakeHeadGrid.x = snakeLimitRight
		if(snakeHeadGrid.y < snakeLimitUp):
			snakeHeadPos.y = snakeLimitDown
			snakeHeadGrid.y = snakeLimitDown
		readyToChangeDir = true
		snakeGridQueue.push_front(snakeHeadGrid)
		grid.getCase(snakeGridQueue[-1].x, snakeGridQueue[-1].y).set_frame(0)
		snakeGridQueue.pop_back()	
	
	grid.drawSnake(snakeGridQueue)
	


