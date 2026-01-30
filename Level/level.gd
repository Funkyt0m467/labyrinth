extends Node3D

const WALL := preload("res://Level/Wall.tscn")

var width: int = 19
var height: int = width

var grid: Array = [] #2D grid of bools, wall = true, path = false
var walls: Array[CSGBox3D] = [] #Array of boxes for each wall section

func _ready():
	
	#Guarranty width and height to be odd for outter walls
	if width%2 == 0:
		width+=1
	if height%2 == 0:
		height+=1
	
	_generate_grid()
	#print_grid()
	
	_generate_level()

#Debug fonction to check how the var grid looks like
func print_grid():
	var output := ""

	for y in grid.size():
		for x in grid[y].size():
			output += "██" if grid[y][x] else "  "
		output += "\n"

	print(output)

func _generate_grid():
	_init_grid()
	_carve(Vector2i((width-1)>>1, height-2))
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
	grid[height-1][mid_x] = false #Entry
	grid[0][mid_x] = false #Exit

func _generate_level():
	for z in grid.size():
		for x in grid[z].size():
			if grid[x][z]:
				_generate_wall(x, z)
			else:
				pass #Here can be added any other spawned objects

func _generate_wall(x:int, z:int):
	
	var wall = WALL.instantiate()
	add_child(wall)
	
	wall.global_position.x = x * wall.get_child(0).mesh.size.x
	wall.global_position.z = (z-((width-1)>>1)) * wall.get_child(0).mesh.size.z
