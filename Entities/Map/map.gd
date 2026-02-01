extends Control

var player_pos: Vector3

@onready var level: Node = get_parent()
@onready var grid: Array = level.grid
@onready var maze_size: Vector2i = Vector2i(level.width, level.height)
@onready var wall_size: Vector3 = level.wall_size
@onready var map_wall_size: Vector2 = Vector2(300.0/maze_size.x, 300.0/maze_size.y) #Size of the 2D wall on the map
@onready var maze_pos: Vector2 = %MazePosition.position #Place the position of the maze on the map using marker

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	create_maze()
	place_player()

func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("map"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.queue_free()

func create_maze():
	
	var current_position: Vector2 = Vector2.ZERO
	
	for y in range(grid.size() - 1, -1, -1): #This way the start is at the bottom, end at the top
		for x in grid[y].size():
			current_position.x = map_wall_size.x*x
			if grid[y][x]:
				create_wall(current_position + maze_pos)
		current_position.y += map_wall_size.y

func create_wall(_position:Vector2):
	
	var rect := TextureRect.new()
	rect.texture = load("res://Assets/StoneWall/rock_wall_08_diff_1k.jpg")
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.expand = true
	
	rect.size = Vector2(map_wall_size.x, map_wall_size.y)
	rect.position = Vector2(_position.x, _position.y)
	rect.modulate = Color(1, 0.1, 0, 0.5)
	
	get_child(0).add_child(rect)

func place_player():
	var rect := TextureRect.new()
	rect.texture = load("res://Assets/StoneWall/rock_wall_08_diff_1k.jpg")
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.expand = true
	
	rect.size = Vector2(map_wall_size.x, map_wall_size.y)
	rect.modulate = Color(1, 0, 0, 1)
	
	var grid_player_pos: Vector2i
	grid_player_pos.x = int((player_pos.z+0.5*wall_size.z)/wall_size.z) + ((maze_size.x-1)>>1)
	grid_player_pos.y = int(-(player_pos.x+0.5*wall_size.x)/wall_size.x) + (maze_size.y-1)
	
	var map_player_pos: Vector2
	map_player_pos.x = map_wall_size.x*grid_player_pos.x
	map_player_pos.y = map_wall_size.y*grid_player_pos.y
	
	rect.position = map_player_pos + maze_pos
	
	get_child(0).add_child(rect)
