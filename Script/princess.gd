extends AnimatedSprite2D

const SPEED = 6

enum direction{ left, right, up, down }

var pos = Vector2i(0,0)
var canMove = false
var moveVector = Vector2i.ZERO

var oldPos = Vector2i.ZERO
var targetPos = Vector2i.ZERO
var inTransit = false
var transitTimer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	play("Anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_input(delta)


func move_input(delta):
	if !inTransit:
		if canMove:
			if Input.is_action_pressed("move_left"):
				if pos.x > 0 && GameManager.borderMap[pos.y * 2][pos.x - 1] == 0:
					moveVector = Vector2i.LEFT
				else:
					moveVector = Vector2i.ZERO
			if Input.is_action_pressed("move_right"):
				if pos.x < GameManager.GRIDMAP_MAXX - 1 && GameManager.borderMap[pos.y * 2][pos.x]==0:
					moveVector = Vector2i.RIGHT
				else:
					moveVector = Vector2i.ZERO
			if Input.is_action_pressed("move_up"):
				if pos.y > 0 && GameManager.borderMap[pos.y * 2 - 1][pos.x] == 0:
					moveVector = Vector2i.UP
				else:
					moveVector = Vector2i.ZERO
			if Input.is_action_pressed("move_down"):
				if pos.y < GameManager.GRIDMAP_MAXY - 1 && GameManager.borderMap[pos.y * 2 + 1][pos.x] == 0:
					moveVector = Vector2i.DOWN
				else:
					moveVector = Vector2i.ZERO
		oldPos = pos
		if moveVector != Vector2i.ZERO:
			targetPos = pos + moveVector
			inTransit = true
		moveVector = Vector2i.ZERO
				
	if inTransit:
		var oldPosition = GameManager.grid_to_position(oldPos)
		var targetPosition = GameManager.grid_to_position(targetPos)
		transitTimer += delta
		position = lerp(oldPosition, targetPosition, transitTimer * SPEED)
		if transitTimer * SPEED >= 1:
			#print("transit stop ", targetPos.x, targetPos.y)
			inTransit = false
			pos = targetPos
			transitTimer = 0
			handle_dest(targetPos)

func initialize_pos():
	for i in GameManager.GRIDMAP_MAXY:
		for j in GameManager.GRIDMAP_MAXX:
			if GameManager.gridMap[i][j]==GameManager.mapGrid.PLAYER:
				pos = Vector2i(j,i)
				position = GameManager.grid_to_position(pos)
				

#enum mapGrid {EMPTY = 0, PLAYER = 1, PRINCE = 2, PORTAL_CIRCLE = 10, PORTAL_TRIANGLE = 20}
func handle_dest(dest: Vector2i):
	match GameManager.gridMap[dest.y][dest.x]:
		GameManager.mapGrid.EMPTY:
			return
		GameManager.mapGrid.PRINCE:
			#print("win!")
			canMove = false
			GameManager.win_game()
			return
		GameManager.mapGrid.PORTAL_CIRCLE:
			#print("enter portal 1")
			pos = find_other_portal(GameManager.mapGrid.PORTAL_CIRCLE)
			position = GameManager.grid_to_position(pos)
			return
		GameManager.mapGrid.PORTAL_TRIANGLE:
			#print("enter portal 2")
			pos = find_other_portal(GameManager.mapGrid.PORTAL_TRIANGLE)
			position = GameManager.grid_to_position(pos)
			return
	return

func find_other_portal(type: GameManager.mapGrid):
	for i in GameManager.GRIDMAP_MAXY:
		for j in GameManager.GRIDMAP_MAXX:
			if GameManager.gridMap[i][j] == type && Vector2i(j,i) != pos:
				return Vector2i(j,i)
	print("error on finding portal")
	return Vector2i.ZERO
