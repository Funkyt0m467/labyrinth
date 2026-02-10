extends CharacterBody3D

const SPEED = 5.0

var grid: Array
var grid_size: Vector2i #Is (Width, height) of the grid
var wall_size: Vector3

var targets: Array

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("player")[0]
@onready var agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(_delta: float) -> void:
	
	if agent.target_position and agent.is_navigation_finished():
		
		#print(targets)
		targets.pop_front() #Remove the reached target on the list
		
		#if targets.size() <= 3: #This means minautor is at 3 tile from the player
			#Should play a sound
		if targets.size() > 1:
			agent.target_position = _get_pos(targets[0]) #Target the next one now in first
		else: game_over() 
	
	var direction := (agent.get_next_path_position() - global_position).normalized()
	if direction:
		velocity = velocity.move_toward(direction * SPEED, 0.25)
	else:
		velocity = Vector3.ZERO

	if player.in_map_or_camera: move_and_slide()

func set_target(): #Set by the player on entering the map
	targets = _astar(_entity_grid_pos(self), _entity_grid_pos(player))
	if targets.size() <= 1: game_over()
	targets.pop_front() #First pos is it's own so remove it
	agent.target_position = _get_pos(targets[0]) #First target
	
	print("Minotaur's position = ")
	print(_entity_grid_pos(self))
	print("Target grid position = ")
	print(targets[0])

func _entity_grid_pos(entity: CharacterBody3D) -> Vector2i:
	var grid_pos: Vector2i
	grid_pos.x = floor(entity.global_position.x/wall_size.x+0.5) + ((grid_size.x-1)>>1)
	grid_pos.y = floor(entity.global_position.z/wall_size.z+0.5) + (grid_size.y-1)
	return grid_pos

func _get_pos(grid_pos: Vector2i) -> Vector3:
	
	var pos: Vector3
	
	pos.x = (grid_pos.x - ((grid_size.x-1)>>1)) * wall_size.x
	pos.y = 0
	pos.z = (grid_pos.y - (grid_size.y-1)) * wall_size.z
	
	return pos

func _astar(start: Vector2i, goal: Vector2i) -> Array:
	
	var open: Array = [start]
	var open_l: Dictionary = {start: true}
	var closed: Dictionary = {}
	var g: Dictionary = {start: 0}
	var from: Dictionary = {}

	while open.size() > 0:
		var current: Vector2i = open[0]
		var best_f: int = int(g[current]) + abs(current.x - goal.x) + abs(current.y - goal.y)
		
		for n in open:
			var f: int = int(g[n]) + abs(n.x - goal.x) + abs(n.y - goal.y)
			if f < best_f:
				best_f = f
				current = n

		if current == goal:
			var path: Array = [current]
			while from.has(current):
				current = from[current]
				path.push_front(current)
			return path

		open.erase(current)
		open_l.erase(current)
		closed[current] = true

		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var nb: Vector2i = current + d
			if nb.y < 0 or nb.y >= grid.size(): continue
			if nb.x < 0 or nb.x >= grid[0].size(): continue
			if grid[nb.y][nb.x] or closed.has(nb): continue

			var ng: int = int(g[current]) + 1
			if not g.has(nb) or ng < g[nb]:
				g[nb] = ng
				from[nb] = current
				if not open_l.has(nb):
					open.append(nb)
					open_l[nb] = true

	return []

func game_over() -> void: #TODO Game over screen
	
	print("Game over")
	
	await TransAnim.fade_out()
	
	var menu = load("res://Menu/Menu.tscn").instantiate()
	get_node("/root").add_child(menu)
	
	get_parent().queue_free()
	
	await TransAnim.fade_in()
