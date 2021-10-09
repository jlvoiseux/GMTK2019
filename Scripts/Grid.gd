extends Node2D

var caseArray = []
var gridWidth = 32
var gridHeight = 18
var shakeAnim
var resetWinFlag
var blinkTimer
var blinkTimeWin = 0.005
var blinkTimeLose = 0.001
var eraseFlag = true
var currentX = 0
var currentY = 0
var initialFrame = 0
var gridReady = true
var finalColor = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shakeAnim = get_node("Shake")
	caseArray.append(get_node("AnimatedSprite"))	
	for i in range(575):
		caseArray.append(get_node("AnimatedSprite" + String(i+2)))
	
	blinkTimer = Timer.new()
	blinkTimer.connect("timeout",self,"resetBlink") 
	add_child(blinkTimer) #to process
	blinkTimer.set_wait_time(blinkTimeWin)
	blinkTimer.set_one_shot(true)
		
func shake():
	shakeAnim.play("Shake")
	
func resetGrid():
	for i in range(576):
		caseArray[i].set_frame(0)

func getCase(x, y):
	return caseArray[y*gridWidth + x]

func drawSnake(positionQueue):
	for pos in positionQueue:
		getCase(pos.x, pos.y).set_frame(1)

func eraseSnake(positionQueue):
	for pos in positionQueue:
		getCase(pos.x, pos.y).set_frame(0)

func drawTarget(x, y, size):
	if(x < gridWidth && y < gridHeight):
		if size == 1:
			getCase(x, y).set_frame(2)
		elif size == 2:
			getCase(x, y).set_frame(2)
			getCase(x+1, y).set_frame(2)
			getCase(x-1, y).set_frame(2)
			getCase(x, y+1).set_frame(2)
			getCase(x, y-1).set_frame(2)
		elif size == 3:
			getCase(x, y).set_frame(2)
			getCase(x+1, y).set_frame(2)
			getCase(x-1, y).set_frame(2)
			getCase(x, y+1).set_frame(2)
			getCase(x, y-1).set_frame(2)
			getCase(x+1, y+1).set_frame(2)
			getCase(x-1, y+1).set_frame(2)
			getCase(x-1, y+1).set_frame(2)
			getCase(x-1, y-1).set_frame(2)

func drawBullet(x, y):
	getCase(x, y).set_frame(3)

func resetCase(x, y):
	getCase(x, y).set_frame(1)
	
func drawFood(x, y):
	getCase(x, y).set_frame(4)
	
func oneBlink(x, y, color, erase):
	finalColor = color
	if color == 0:
		blinkTimer.set_wait_time(blinkTimeWin)
	else:
		blinkTimer.set_wait_time(blinkTimeLose)
	gridReady = false
	currentX = x
	currentY = y
	initialFrame = getCase(x, y).get_frame()
	getCase(x, y).set_frame(5)
	if erase:
		eraseFlag = true
	else:
		eraseFlag = false
	blinkTimer.start()
	
func resetBlink():
	if eraseFlag:
		getCase(currentX, currentY).set_frame(finalColor)
	else:
		getCase(currentX, currentY).set_frame(initialFrame)
	gridReady = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
