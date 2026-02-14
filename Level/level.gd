extends Node3D

const WALL := preload("res://Level/Wall/Wall.tscn")

@export var width: int = 47 #Should be of the from 4k+3
@export var height: int = 47 #Should be odd

@export var camera_count: int = 16 #Should be of the form n²

@export var time: int = 300 #Time to complete the maze

var grid: Array = [] #2D grid of bools, wall = true, path = false
var pathways: Array[Vector2i] = [] #Track the pathways, tiles without walls (used to place cameras, minotaur etc...)

var cameras: Dictionary = {} #Stores the cameras with the key as position x+y of the camera (unique)
var camera_positions: Array[Vector2i] = []

var walls: Array[CSGBox3D] = [] #Array of boxes for each wall section
var wall_size: Vector3

func _ready():
	_check_size() #Verify maze has a valid size
	
	_generate_grid()
	#_print_grid()
	
	_generate_level()
	_set_cameras()
	_spawn_minotaur()

func _check_size():
	if width%4!=3:
		push_error("Width must be of the form 4k + 3")
	if height%2!=1:
		push_error("Height must be odd")

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
	
	grid[cell.y][cell.x] = false

	var directions: Array[Vector2i] = [
		Vector2i(0, -2),
		Vector2i(2, 0),
		Vector2i(0, 2),
		Vector2i(-2, 0)
	]
	directions.shuffle()

	for dir:Vector2i in directions:
		var next:Vector2i = cell + dir
		if next.x > 0 and next.x < width-1 and next.y > 0 and next.y < height-1 and grid[next.y][next.x]:
			#Carve the wall between
			var between:Vector2i = cell + dir/2
			grid[between.y][between.x] = false
			_carve(next)

func _create_entry_and_exit():
	var mid_x: int = (width-1)>>1
	grid[0][mid_x] = false #Entry
	grid[height-1][mid_x] = false #Exit

func _generate_level():
	for y in grid.size():
		for x in grid[y].size():
			var pos = Vector2i(x, y)
			if grid[y][x]: _generate_wall(x, y)
			else:
				var mid_x: int = (width-1)>>1
				if pos != Vector2i(mid_x, 0) and pos != Vector2i(mid_x, height-1): #Not at the entry or exit
					pathways.append(Vector2i(x, y))

func _generate_wall(x:int, z:int):
	
	var wall = WALL.instantiate()
	%Walls.add_child(wall)
	
	wall_size = wall.get_child(0).mesh.size
	
	wall.global_position.x = (x-((width-1)>>1)) * wall_size.x
	wall.global_position.z = (z-(height-1)) * wall_size.z

func _set_cameras():
	
	#TODO Fix this because it only works for :
	#maze size 11,11 or 11,31 camera_count 1 or 4 not 16
	#maze size 31,31 or 31,11 camera count 1 or 4 or 16
	#Seems like weight need to be almost twice camera_count (not height ?)
	
	var sections: Array  #Array of the section, each are Array[Vector2i] storing all pos of paths in it
	for n in camera_count: #There is a section for each camera
		var section: Array[Vector2i] = []
		sections.append(section)
	
	var section_size: Vector2i
	var nbr_of_sections: int = int(sqrt(camera_count))
	
	#With this division the size should exclude the 2 outter walls and the center row/line
	@warning_ignore("integer_division")
	section_size.x = int((width-3) / nbr_of_sections)
	@warning_ignore("integer_division")
	section_size.y = int((height-3) / nbr_of_sections)
	
	for i in pathways.size():
		
		#Leaves the middle parts because camaera_count is even and maze sizes are even
		if pathways[i].x == (width-1)>>1 or pathways[i].y == (height-1)>>1:
			continue
		
		@warning_ignore("integer_division")
		var x = int((pathways[i].x-2)/section_size.x)
		@warning_ignore("integer_division")
		var y = int((pathways[i].y-2)/section_size.y)
		
		var n = y*nbr_of_sections + x
		
		sections[n].append(pathways[i])
	
	for n in camera_count:
		
		sections[n].shuffle()
		camera_positions.append(sections[n][0])
	
	for pos in camera_positions:
		_generate_camera(pos.x, pos.y)

func _generate_camera(x:int, z:int):
	var camera := Camera3D.new()
	%Cameras.add_child(camera)
	cameras[x+z] = camera
	
	camera.global_position.x = (x-((width-1)>>1)) * wall_size.x
	camera.global_position.y = wall_size.y + 15 #10 above the wall to see a larger space
	camera.global_position.z = (z-(height-1)) * wall_size.z
	
	camera.rotation_degrees.x = -90 #Look straight down on init
	
	var light = load("res://Entities/Light/Light.tscn").instantiate()
	camera.add_child(light)
	
	camera.visible = false

func _spawn_minotaur():
	
	var minotaur: CharacterBody3D = %Minotaur
	
	#TODO put the minotaur in the middle maybe ?
	#Sets the minotaur in a pathway that's not the same as a camera one (the first pathways)
	minotaur.global_position.x = 0
	minotaur.global_position.y = 0
	minotaur.global_position.z = -((height-1)>>1) * wall_size.z
	
	minotaur.visible = true
	
	minotaur.grid = grid #Passing the grid for pathfinding
	minotaur.grid_size = Vector2i(width, height)
	minotaur.wall_size = wall_size
