class_name Menu extends Control

func _ready() -> void:
	pass

func _on_play_button_down() -> void:
	switch_scene("res://Level/Level.tscn")

func _on_settings_button_down() -> void:
	switch_scene("res://Menu/Settings.tscn")

func switch_scene(_path:String):
	
	await TransAnim.fade_out()
	
	var level = load(_path).instantiate()
	get_parent().add_child(level)
	
	self.queue_free()
	
	await TransAnim.fade_in()

func _on_exit_button_down() -> void:
	get_tree().quit()
