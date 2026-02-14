extends CharacterBody3D

const SPEED = 20.0

@export var min_distance: float = 4

var grid: Array
var grid_size: Vector2i #Is (Width, height) of the grid
var wall_size: Vector3

var routines: Array[Vector2i]
var targets: Array

var in_transition: bool = false

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("player")[0]
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var sight: RayCast3D = $RayCast3D

#TODO Routine (path around the spawn = middle, cyclic)

func _physics_process(_delta: float) -> void:
	
	if _in_sight():
		chase()
	elif player.in_map_or_camera and targets:
		go_to_player()
	else:
		routine()
	
	var direction := (agent.get_next_path_position() - global_position).normalized()
	if direction:
		#TODO For less robotic mouv consider using
		#velocity.move_toward(direction * SPEED, turn sharpness between 0-1 (1=sharp))
		#But only when velocity isn't too hight or not in corners
		velocity = direction * SPEED
	else:
		velocity = Vector3.ZERO

	move_and_slide()

func set_target(): #Set by the player on entering the map
	
	targets = _astar(_entity_grid_pos(self), _entity_grid_pos(player))
	
	targets.pop_front() #First pos is it's own so remove it
	if targets: agent.target_position = _get_pos(targets[0]) #First target if any left
	else: return
	
	print("Minotaur's position = ")
	print(_entity_grid_pos(self))
	print("Target grid position = ")
	print(targets[0])

func chase():
	agent.target_position = player.global_position
	if agent.distance_to_target() <= min_distance:
		game_over()

func go_to_player():
	
	if agent.is_navigation_finished():
		
		print(targets.size())
		targets.pop_front() #Remove the reached target on the list
		
		#if targets.size() <= 3: #This means minautor is at 3 tile from the player
			#Should play a sound
		if targets.size() > 1: #When less it should be next to the player and see it
			agent.target_position = _get_pos(targets[0]) #Target the next one now in first

func routine():
	if routines: agent.target_position = _get_pos(routines[0])

#BUG sometimes see the player when not in sight ?
func _in_sight():
	#Squared lenght is used to be less expensive, max distance can be larger but should be at least level sized
	var max_dist: float = grid_size.length_squared()*wall_size.length_squared()
	
	sight.target_position = max_dist*(player.global_position - global_position).normalized()
	sight.force_raycast_update()
	
	if sight.is_colliding() and sight.get_collider() == player:
		print("PLAYER SEEN!")
		return true
	
	return false

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
	
	if in_transition: return
	
	in_transition = true
	
	print("Game over")
	
	await TransAnim.fade_out()
	
	var menu = load("res://Menu/Menu.tscn").instantiate()
	get_node("/root").add_child(menu)
	
	get_parent().queue_free()
	
	await TransAnim.fade_in()
