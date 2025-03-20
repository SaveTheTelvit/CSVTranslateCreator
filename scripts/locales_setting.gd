extends Control

@onready var text_edit : TextEdit = $MarginContainer/VBoxContainer/TextEdit

func open():
	update_locales()
	show()

func close():
	hide()

func update_locales() -> void:
	$MarginContainer/VBoxContainer/TextEdit.clear()
	for i in GlobalInfo.locales.size():
		if i != 0:
			text_edit.text += " "
		text_edit.text += GlobalInfo.locales[i] + ","

func accept() -> void:
	var str : String = $MarginContainer/VBoxContainer/TextEdit.text
	var arr : PackedStringArray = str.strip_edges().split(",", false)
	for i in arr.size():
		arr[i] = arr[i].strip_edges()
	GlobalInfo.locales = arr
	update_locales()
	$MarginContainer/VBoxContainer/HBoxContainer/Button.grab_focus()

func _on_button_pressed() -> void:
	accept()

func _on_text_edit_accepted() -> void:
	accept()
