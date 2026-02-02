extends CharacterBody3D

@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 10.0
@export var JUMP_VELOCITY: float = 4.5

@export var BASE_FOV: float = 75.0
@export var FOV_CHANGE: float = 0.4

var sensitivity: float = 0.005

var map: Control

var _speed: float = WALK_SPEED

@onready var level: Node = get_parent()
@onready var player_camera: Camera3D = $Camera3D
@onready var camera: Camera3D = player_camera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("escape"):
		var popup_menu = preload("res://Menu/PopupMenu.tscn").instantiate()
		popup_menu.map_opened = map #Tell the menu if map exist (aka is opened)
		get_parent().add_child(popup_menu)
	
	if(!map): #open map or look around only when map isn't opened
	
		if Input.is_action_just_pressed("map"):
			map = preload("res://Entities/Map/Map.tscn").instantiate()
			map.player_pos = global_position
			map.player_camera = player_camera
			get_parent().add_child(map)
		
		#Camera mouvement
		if event is InputEventMouseMotion:
			self.rotate_y(-event.relative.x*sensitivity)
			camera.rotate_x(-event.relative.y*sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	
	if(map):
		_speed = 0 #Stop when map opened
	elif Input.is_action_pressed("sprint"):
		_speed = SPRINT_SPEED
	else:
		_speed = WALK_SPEED
	
	#Get the input direction and handle the movement/deceleration
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
	
	#Change FOV on sprint
	var velocity_clamped: float = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov: float = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if(!map): move_and_slide()
