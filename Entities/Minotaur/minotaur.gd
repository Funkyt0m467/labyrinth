extends CharacterBody3D

const SPEED = 5.0

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("player")[0]
@onready var agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	pass
	#print(target.global_position)

func _physics_process(_delta: float) -> void:
		
	agent.target_position = player.global_position
	
	if agent.is_navigation_finished():
		print("Game over") #TODO Game over screen
		return
	
	var direction := (agent.get_next_path_position() - global_position).normalized()
	if direction:
		velocity = velocity.move_toward(direction * SPEED, 0.25)
	else:
		velocity = Vector3.ZERO

	move_and_slide()
