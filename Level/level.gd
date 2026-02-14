extends Node3D

const WALL := preload("res://Level/Wall/Wall.tscn")

@export var width: int = 11 #Should be of the from 4k+3
@export var height: int = 11 #Should be odd

@export var camera_count: int = 4

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
	_set_minotaur()

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
	
	var sections: Array  #Array of the section, each are Array[Vector2i] storing all pos of paths in it
	for n in camera_count: #There is a section for each camera
		var section: Array[Vector2i] = []
		sections.append(section)
	
	var nbr_of_sections: Vector2i = _closest_ratio_pair(camera_count, width, height)
	var section_size: Vector2 = Vector2i(width, height)/nbr_of_sections
	
	var sections_center: Array[Vector2] = []
	var offset: Vector2 = (Vector2(width, height)-(Vector2(nbr_of_sections)-Vector2(1, 1))*section_size)/2
	for y in nbr_of_sections.y:
		for x in nbr_of_sections.x:
			sections_center.append(Vector2(x, y) * section_size + offset)
	
	for path in pathways:
		for n in sections_center.size():
			if _scaled_chebyshev_distance(path, sections_center[n], section_size) <= 1:
				sections[n].append(path)
				continue
	
	for n in camera_count:
		
		sections[n].shuffle()
		camera_positions.append(sections[n][0])
	
	for pos in camera_positions:
		_generate_camera(pos.x, pos.y)

func _closest_ratio_pair(n: int, _width: float, _height: float) -> Vector2i:
	
	var target: float = _width/_height
	var best_pair: Vector2i = Vector2i(n, 1)
	var best_diff: float = INF

	for i in range(1, int(sqrt(float(n))) + 1):
		if n%i == 0:
			var x: int = i
			@warning_ignore("integer_division")
			var y: int = int(n/i)

			var ratio: float = float(x) / float(y)
			var diff: float = abs(ratio - target)

			if diff < best_diff:
				best_diff = diff
				best_pair = Vector2i(x, y)
	
	return best_pair

func _scaled_chebyshev_distance(a: Vector2, b: Vector2, rect_size: Vector2 = Vector2(1, 1)) -> float:
	var x: float = 2*abs(b.x-a.x)/rect_size.x
	var y: float = 2*abs(b.y-a.y)/rect_size.y
	return max(x, y)

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

func _set_minotaur():
	
	var minotaur: CharacterBody3D = %Minotaur
	
	minotaur.visible = true
	
	minotaur.grid = grid #Passing the grid for pathfinding
	minotaur.grid_size = Vector2i(width, height)
	minotaur.wall_size = wall_size
	
	var center_section: Array[Vector2i]
	var center: Vector2 = Vector2(float(width-1)/2, float(height-1)/2)
	for path in pathways:
		if _scaled_chebyshev_distance(path, center, center) <= 1:
			center_section.append(path)
	center_section.shuffle()
	
	minotaur.routines = center_section.slice(0, minotaur.nbr_of_routine_point)
	minotaur.set_routine()
	
	minotaur.global_position = minotaur.get_pos(center_section[0])
