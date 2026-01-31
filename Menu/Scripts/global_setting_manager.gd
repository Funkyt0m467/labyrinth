extends Node

const CONFIG_PATH = "user://settings.cfg"

const DEFAULTS = {
	"video/screen": 0,
	"video/mode": "SETTING_VIDEO_WINDOWED",
	"video/resolution": Vector2i(960,540),
	"control/map": {}, #null dictionary sets it to the project settings map
	"ui/language": ""
}

var settings = {}

func _ready() -> void:
	load_settings()
	if get_setting("ui/language") == "":
		if OS.get_locale().begins_with("fr"): set_setting("ui/language", "fr")
		else: set_setting("ui/language", "en")
	for key in settings:
		apply_setting(key)

func apply_setting(key: String):
	if(key == "video/screen"): _apply_screen()
	if(key == "video/mode"): _apply_mode()
	elif(key == "video/resolution"): _apply_resolution()
	elif(key == "control/map"): _apply_input_map()
	elif(key == "ui/language"): _apply_language()

#TODO set positions of the window
#BUG in some changes in res/modes

func _apply_screen() -> void:
	DisplayServer.window_set_current_screen(settings["video/screen"])

func _apply_mode() -> void:
	
	var mode: String = settings["video/mode"]
	
	if(mode == "SETTING_VIDEO_BORDERLESS"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	
	if(mode == "SETTING_VIDEO_WINDOWED"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif(mode == "SETTING_VIDEO_FULLSCREEN"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _apply_resolution() -> void:
	DisplayServer.window_set_size(settings["video/resolution"])

func _apply_input_map() -> void:
	
	#TODO
	pass

func _apply_language() -> void:
	TranslationServer.set_locale(settings["ui/language"])

func load_settings() -> void:
	
	var config = ConfigFile.new()
	config.load(CONFIG_PATH)
	
	for key in DEFAULTS:
		var section = key.split("/")[0]
		var settting = key.split("/")[1]
		settings[key] = config.get_value(section, settting, DEFAULTS[key])

func save_settings() -> void:
	
	var config = ConfigFile.new()
	
	for key in settings.keys():
		var section = key.split("/")[0]
		var settting = key.split("/")[1]
		config.set_value(section, settting, settings[key])
	
	config.save(CONFIG_PATH)

func get_setting(key: String):
	return settings.get(key)

func set_setting(key: String, value) -> void:
	settings[key] = value
	save_settings()
