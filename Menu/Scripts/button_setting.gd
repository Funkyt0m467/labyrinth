class_name ButtonSetting

var button: OptionButton
var id: String
var text: Array
var value: Array

func _init(_button: OptionButton, _id: String, _text: Array, _value: Array = []) -> void:
	button = _button
	id = _id
	text = _text
	if(_value): value = _value
	else: value = _text
