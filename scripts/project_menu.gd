extends Control

signal file_name_selected(file_name : String)
signal remove_file_called(file_name : String)

@onready var item_list : ItemList = $MarginContainer/VBoxContainer/HBoxContainer/ItemList
@onready var new_project_line = $MarginContainer/VBoxContainer/HBoxContainer3

var remove_index : int = -1

func call_menu(data : PackedStringArray):
	item_list.clear()
	$MarginContainer/VBoxContainer/HBoxContainer3/LineEdit.text = ""
	for file_name in data:
		item_list.add_item(file_name)
	item_list.add_item("Создать новый проект")
	$MarginContainer/VBoxContainer/HBoxContainer2/Label.text = "Список проектов"
	$MarginContainer/VBoxContainer/HBoxContainer.show()
	$MarginContainer/VBoxContainer/HBoxContainer3.hide()

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if index == item_list.item_count - 1:
			new_project_line.show()
			$MarginContainer/VBoxContainer/HBoxContainer.hide()
			$MarginContainer/VBoxContainer/HBoxContainer2/Label.text = "Новый проект"
			return
		file_name_selected.emit(item_list.get_item_text(index))
	elif (mouse_button_index == MOUSE_BUTTON_RIGHT and 
	index != item_list.item_count - 1):
		$PopupMenu.position = get_global_mouse_position()
		remove_index = index
		$PopupMenu.show()

func _on_button_pressed():
	file_name_selected.emit($MarginContainer/VBoxContainer/HBoxContainer3/LineEdit.text)

func _on_line_edit_text_submitted(new_text):
	file_name_selected.emit(new_text)

func _on_popup_menu_index_pressed(index):
	remove_file_called.emit(item_list.get_item_text(remove_index))
	item_list.remove_item(remove_index)
	remove_index = -1
