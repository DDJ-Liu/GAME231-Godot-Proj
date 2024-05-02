extends Node

const SCREEN_SIZE = Vector2i(240,160)
const SCREEN_SCALE = 4

const START_MAP_POINT = Vector2i(40,24)
const UNIT_DISTANCE = 24

const GRIDMAP_MAXX = 7
const GRIDMAP_MAXY = 5

const BORDER_HORIZONTAL_MAXX = 7
const BORDER_HORIZONTAL_MAXY = 4
const BORDER_HORIZONTAL_STARTX = 37
const BORDER_HORIZONTAL_STARTY = 41

const BORDER_VERTICAL_MAXX = 6
const BORDER_VERTICAL_MAXY = 5
const BORDER_VERTICAL_STARTX = 57
const BORDER_VERTICAL_STARTY = 21

const GAME_LENGTH = 8

enum gameState {MENU, GAME, WIN, LOSE}
enum mapGrid {EMPTY = 0, PLAYER = 1, PRINCE = 2, PORTAL_CIRCLE = 10, PORTAL_TRIANGLE = 20}

var playerScene = preload("res://Nodes/princess.tscn")
var targetScene = preload("res://Nodes/prince.tscn")
var portal1Scene = preload("res://Nodes/portal_circle.tscn")
var portal2Scene = preload("res://Nodes/portal_triangle.tscn")
var borderVerticalSprite = preload("res://Nodes/vertical_border.tscn")
var borderHorizontalSprite = preload("res://Nodes/horizontal_border.tscn")
var bombScene = preload("res://Nodes/bomb.tscn")

var menuScene = preload("res://Nodes/menu.tscn")

var player
var target
var portal1:Array[AnimatedSprite2D]
var portal2:Array[AnimatedSprite2D]
var borders = []
var bomb 

var menu

var state = gameState.GAME
var timer = GAME_LENGTH
var winning = false




#0: empty 
#1: princess(player) 
#2: prince(destination)
#10: portal circle
#20: portal triangle
var gridMap = [
	[0,20,0,0,0,2,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,10,0,0,0,0,0],
	[0,1,0,0,10,20,0]
]
# odd: vertical border
# even: horizontal border
var borderMap = [
	[1,1,1,1,0,1],
	[0,0,0,0,0,1,0],
	[1,0,1,0,1,0],
	[0,0,0,1,0,1,0],
	[0,1,1,0,0,1],
	[0,0,0,0,1,0,0],
	[1,1,1,1,0,1],
	[0,1,0,0,1,1,0],
	[0,0,1,0,1,0]
]


# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()
	set_map()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update(delta)


func initialize():
	get_viewport().size = SCREEN_SIZE * SCREEN_SCALE
	
	#game initialize
	player = playerScene.instantiate()
	add_child(player)
	target = targetScene.instantiate()
	add_child(target)
	portal1.append(portal1Scene.instantiate())
	portal1.append(portal1Scene.instantiate())
	portal2.append(portal2Scene.instantiate())
	portal2.append(portal2Scene.instantiate())
	add_child(portal1[0])
	add_child(portal1[1])
	add_child(portal2[0])
	add_child(portal2[1])
	bomb = bombScene.instantiate()
	add_child(bomb)
	ini_border()
	
	#UI initialize
	var UI = Control.new()
	add_child(UI)
	menu = menuScene.instantiate()
	UI.add_child(menu)
	
func handle_input():
	pass	
	

func update(delta):
	if state == gameState.GAME:
		timer -= delta
		if timer <= 5 && timer > 0:
			bomb.play("explode")
		if timer <= 0:
			#print("endgame")
			end_game()
	

func render():
	pass
	

func set_map():
	player.initialize_pos()
	set_grid()
	set_border()
	timer = GAME_LENGTH
	winning = false
	player.canMove = true

func set_grid():
	var portal1Index = 0
	var portal2Index = 0
	for i in GRIDMAP_MAXY:
		for j in GRIDMAP_MAXX:
			match gridMap[i][j]:
				mapGrid.PRINCE:
					target.position = grid_to_position(Vector2i(j,i))
				mapGrid.PORTAL_CIRCLE:
					portal1[portal1Index].position = grid_to_position(Vector2i(j,i))
					portal1Index = portal1Index + 1
				mapGrid.PORTAL_TRIANGLE:
					portal2[portal2Index].position = grid_to_position(Vector2i(j,i))
					portal2Index = portal2Index + 1

func ini_border():
	var borderNode = Node2D.new()
	add_child(borderNode)
	var horizontalIndex = 0
	var verticalIndex = 0
	while horizontalIndex + verticalIndex < BORDER_HORIZONTAL_MAXY + BORDER_VERTICAL_MAXY:
		if verticalIndex < BORDER_VERTICAL_MAXY:
			borders.append([])
			for i in BORDER_VERTICAL_MAXX:
				borders[verticalIndex + horizontalIndex].append(borderVerticalSprite.instantiate())
				borders[verticalIndex + horizontalIndex][i].position = Vector2(BORDER_VERTICAL_STARTX + i * UNIT_DISTANCE, BORDER_VERTICAL_STARTY + verticalIndex * UNIT_DISTANCE)
				borderNode.add_child(borders[verticalIndex + horizontalIndex][i])
			verticalIndex = verticalIndex + 1
		if horizontalIndex < BORDER_HORIZONTAL_MAXY:
			borders.append([])
			for i in BORDER_HORIZONTAL_MAXX:
				borders[verticalIndex + horizontalIndex].append(borderHorizontalSprite.instantiate())
				borders[verticalIndex + horizontalIndex][i].position = Vector2(BORDER_HORIZONTAL_STARTX + i * UNIT_DISTANCE, BORDER_HORIZONTAL_STARTY + horizontalIndex * UNIT_DISTANCE)
				borderNode.add_child(borders[verticalIndex + horizontalIndex][i])
			horizontalIndex = horizontalIndex + 1	


func set_border():
	for i in borders.size():
		for j in borders[i].size():
			if borderMap[i][j] == 0:
				borders[i][j].visible = false
			else:
				borders[i][j].visible = true
	
	
func grid_to_position(gridIndex: Vector2i):
	return Vector2(START_MAP_POINT.x + gridIndex.x * UNIT_DISTANCE, START_MAP_POINT.y + gridIndex.y * UNIT_DISTANCE)
	
func win_game():
	target.play("close")
	winning = true
	pass

func end_game():
	player.canMove = false
	if winning:
		state = gameState.WIN
		#print("win")
	else:
		state = gameState.LOSE
		#print("lose")
