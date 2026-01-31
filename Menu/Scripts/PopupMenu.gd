extends Control

func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.queue_free()

func _exit_tree() -> void:
	get_tree().paused = false

func _on_settings_button_down() -> void:
	self.queue_free()
	var settings = load("res://Menu/Settings.tscn").instantiate()
	settings.context_in_game = true
	get_parent().add_child(settings)

func _on_menu_button_down() -> void:
	
	await TransAnim.fade_out()
	
	var menu = load("res://Menu/Menu.tscn").instantiate()
	get_node("/root").add_child(menu)
	
	get_parent().queue_free()
	
	await TransAnim.fade_in()

func _on_exit_button_down() -> void:
	get_tree().quit()
