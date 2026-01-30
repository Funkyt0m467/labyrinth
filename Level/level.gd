extends Node3D

var width: int = 30
var height: int = 30

var grid: Array = [] #2D grid of bools

func _ready():
	
	#Guarranty width and height to be odd for outter walls
	if width%2 == 0:
		width+=1
	if height%2 == 0:
		height+=1
	
	_init_grid()
	_carve(Vector2i(width/2, height-2))
	_create_entry_and_exit()
	
	#print_grid()

#Debug fonction to check how the var grid looks like
func print_grid():
	var output := ""

	for y in grid.size():
		for x in grid[y].size():
			output += "██" if grid[y][x] else "  "
		output += "\n"

	print(output)

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
		if _in_bounds(next) and grid[next.y][next.x]:
			#Carve the wall between
			var between:Vector2i = cell + dir/2
			grid[between.y][between.x] = false
			_carve(next)

func _create_entry_and_exit():
	var mid_x: int = width/2
	grid[height-1][mid_x] = false #Entry
	grid[0][mid_x] = false #Exit

func _in_bounds(cell: Vector2i) -> bool:
	return cell.x > 0 and cell.x < width-1 and cell.y > 0 and cell.y < height-1
