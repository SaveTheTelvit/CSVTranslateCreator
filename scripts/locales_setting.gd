extends Control

@onready var text_edit : TextEdit = $MarginContainer/VBoxContainer/TextEdit

func open():
	$MarginContainer/VBoxContainer/TextEdit.clear()
	for i in GlobalInfo.locales.size():
		if i != 0:
			text_edit.text += ", "
		text_edit.text += GlobalInfo.locales[i]
	show()

func close():
	hide()

func _on_button_pressed():
	var str : String = $MarginContainer/VBoxContainer/TextEdit.text
	var arr : PackedStringArray = str.strip_edges().split(",", false)
	for i in arr.size():
		arr[i] = arr[i].strip_edges()
	GlobalInfo.locales = arr
