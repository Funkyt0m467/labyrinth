extends Menu

const RESOLUTIONS: Dictionary = {
	"960 x 540" = Vector2i(960, 540),
	"1152 x 648" = Vector2i(1152, 648),
	"1280 x 720" = Vector2i(1280, 720),
	"1920 x 1080" = Vector2i(1920, 1080),
	"2560 x 1440" = Vector2i(2560, 1440)
}
var modes: Array[String] = [
	"SETTING_VIDEO_BORDERLESS",
	"SETTING_VIDEO_WINDOWED",
	"SETTING_VIDEO_FULLSCREEN"]

var context_in_game: bool = false

func _ready() -> void:
	if context_in_game:
		get_tree().paused = true
		%Background.visible = false
	
	for resolution in RESOLUTIONS.keys():
		%Resolutions.add_item(resolution)
	
	for mode in modes:
		%Modes.add_item(mode)

func _input(_event: InputEvent) -> void:
	if context_in_game: get_tree().paused = true
	
	if _event.is_action_pressed("escape"):
		_on_back_button_down()

	#if(modes == "SETTING_VIDEO_BORDERLESS"):
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	#else:
		#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	#
	#if(modes == "SETTING_VIDEO_WINDOWED"):
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#elif(modes == "SETTING_VIDEO_FULLSCREEN"):
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_back_button_down() -> void:
	if context_in_game:
		self.queue_free()
		var popup_menu = load("res://Menu/PopupMenu.tscn").instantiate()
		get_parent().add_child(popup_menu)
	else:
		_switch_scene("res://Menu/Menu.tscn")
