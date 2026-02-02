extends Node3D

const WALL := preload("res://Level/Wall.tscn")

@export var width: int = 31
@export var height: int = width

@export var camera_count: int = 4

var grid: Array = [] #2D grid of bools, wall = true, path = false
var pathways: Array[Vector2i] = [] #Track the pathways, tiles without walls

var cameras: Dictionary = {} #Stores the cameras with the key as position x+y of the camera (unique)
var camera_positions: Array[Vector2i] = []

var walls: Array[CSGBox3D] = [] #Array of boxes for each wall section
var wall_size: Vector3

func _ready():
	
	#Guarranty width and height to be odd for outter walls
	if width%2 == 0:
		width+=1
	if height%2 == 0:
		height+=1
	
	_generate_grid()
	#_print_grid()
	_generate_level()
	_set_cameras()

#Debug fonction to check how the var grid looks like
func _print_grid():
	var output := ""

	for y in grid.size():
		for x in grid[y].size():
			output += "██" if grid[y][x] else "  "
		output += "\n"

	print(output)

func _generate_grid():
	_init_grid()
	_carve(Vector2i((width-1)>>1, 1))
	_create_entry_and_exit()

func _init_grid():
	grid.clear()
	for y in height:
		var row: Array[bool] = []
		for x in width:
			row.append(true)
		grid.append(row)

func _carve(cell: Vector2i):
	
	grid[cell.x][cell.y] = false

	var directions: Array[Vector2i] = [
		Vector2i(0, -2),
		Vector2i(2, 0),
		Vector2i(0, 2),
		Vector2i(-2, 0)
	]
	directions.shuffle()

	for dir:Vector2i in directions:
		var next:Vector2i = cell + dir
		if next.x > 0 and next.x < width-1 and next.y > 0 and next.y < height-1 and grid[next.x][next.y]:
			#Carve the wall between
			var between:Vector2i = cell + dir/2
			grid[between.x][between.y] = false
			_carve(next)

func _create_entry_and_exit():
	var mid_x: int = (width-1)>>1
	grid[0][mid_x] = false #Entry
	grid[height-1][mid_x] = false #Exit

func _set_cameras():
	
	pathways.shuffle() #Randomize the order oth the valid pathways
	#TODO use a 2 stage sampling to make the shuffle more fair :
	#1 create an even spread of the pathways
	#2 take another pathway as emplacement aroung the anchor at random
	camera_positions = pathways.slice(0, camera_count) #Select the first to be camera emplacement
	
	for pos in camera_positions:
		_generate_camera(pos.x, pos.y)

func _generate_level():
	for x in grid.size():
		for y in grid[x].size():
			if grid[y][x]: _generate_wall(x, y)
			else: pathways.append(Vector2i(x, y))

func _generate_wall(x:int, z:int):
	
	var wall = WALL.instantiate()
	add_child(wall)
	
	wall_size = wall.get_child(0).mesh.size
	
	wall.global_position.x = (x-((width-1)>>1)) * wall_size.x
	wall.global_position.z = (z-(height-1)) * wall_size.z

func _generate_camera(x:int, z:int):
	var camera := Camera3D.new()
	add_child(camera)
	cameras[x+z] = camera
	
	camera.global_position.x = (x-((width-1)>>1)) * wall_size.x
	camera.global_position.y = wall_size.y + 10 #10 above the wall to see a larger space
	camera.global_position.z = (z-(height-1)) * wall_size.z
	
	camera.rotation_degrees.x = -90 #Look straight down on init
