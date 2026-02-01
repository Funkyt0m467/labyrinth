extends OmniLight3D

@export var range_variation: float = 10.0
@export var energy_variation: float = 10.0
@export var timer: float = 0.08
@export var timer_range: float = 0.08

var wait_time: float

@onready var _base_range: float = omni_range
@onready var _base_energy: float = light_energy

@onready var _target_range: float = _base_range
@onready var _target_energy: float = _base_energy

func _ready() -> void:
	_flicker()

func _flicker() -> void:
	if(get_tree()!=null):
		
		var variation = randf()
		_target_range = variation * range_variation + _base_range
		_target_energy = variation * energy_variation + _base_energy
		
		wait_time = randf() * timer_range + timer
		
		await get_tree().create_timer(wait_time).timeout
		_flicker()

func _process(delta: float) -> void:
	omni_range = lerp(omni_range, _target_range, delta/wait_time)
	light_energy = lerp(light_energy, _target_energy, delta/wait_time)
