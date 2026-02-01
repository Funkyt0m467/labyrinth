extends Menu

const RESOLUTIONS: Dictionary = {
	"960 x 540" = Vector2i(960, 540),
	"1152 x 648" = Vector2i(1152, 648),
	"1280 x 720" = Vector2i(1280, 720),
	"1920 x 1080" = Vector2i(1920, 1080),
	"2560 x 1440" = Vector2i(2560, 1440)
	}

const MODES: Array[String] = [
	"SETTING_VIDEO_BORDERLESS",
	"SETTING_VIDEO_WINDOWED",
	"SETTING_VIDEO_FULLSCREEN"
	]
	
const LANGUAGES: Dictionary = {
	"English" = "en",
	"Français" = "fr"
	}

var screens: Dictionary = {} #Set a number (key) to each user's screens (value)

var lists: Dictionary = {} #List of ButtonSetting for each setting

var context_in_game: bool = false

func _ready() -> void:
	if context_in_game:
		get_tree().paused = true
		%Background.visible = false
	
	set_sceens_dic()
	
	lists["screens"] = ButtonSetting.new(%Screens, "video/screen", screens.keys(), screens.values())
	lists["modes"] = ButtonSetting.new(%Modes, "video/mode", MODES)
	lists["resolutions"] = ButtonSetting.new(%Resolutions, "video/resolution", RESOLUTIONS.keys(), RESOLUTIONS.values())
	lists["languages"] = ButtonSetting.new(%Languages, "ui/language", LANGUAGES.keys(), LANGUAGES.values())
	
	for list in lists:
		create_list(lists[list])

func _input(_event: InputEvent) -> void:
	if context_in_game: get_tree().paused = true
	
	if _event.is_action_pressed("escape"):
		_on_back_button_down()

func create_list(list: ButtonSetting) -> void:
	
	#create the list of options
	for i in list.text.size():
		list.button.add_item(list.text[i])
	
	#select the saved/default value in the list	
	for i in list.button.item_count:
		if(list.value[i] == SettingManager.get_setting(list.id)):
			list.button.selected = i
			break

func set_sceens_dic() -> void: #Creates the dictionary screens
	for i in range(DisplayServer.get_screen_count()):
		screens[str(i+1)] = i

func _on_list_selected(i: int, list_name: String) -> void: #Used for every lists of settings
	SettingManager.set_setting(lists[list_name].id, lists[list_name].value[i])
	SettingManager.apply_setting(lists[list_name].id)

func _on_back_button_down() -> void:
	if context_in_game:
		self.queue_free()
		var popup_menu = load("res://Menu/PopupMenu.tscn").instantiate()
		get_parent().add_child(popup_menu)
	else:
		switch_scene("res://Menu/Menu.tscn")
