extends HBoxContainer

signal text_edited(data : Dictionary)
signal menu_called(obj : Node)

var store_object : StoreObject = null : set = _set_store_object
var _last_key_store : Dictionary = {}
var _last_key : String = ""
var key : set = _set_key, get = _get_key 
var text : set = _set_text, get = _get_text

func get_parent_obj() -> StoreObject:
	return store_object

func _set_store_object(obj : StoreObject):
	store_object = obj
	if (!key.is_empty()):
		_update_data()

func _update_data():
	if store_object.keys.keys().has(key):
		var locale : String = GlobalInfo.current_locale
		_last_key_store = store_object.keys[key]
		if store_object.keys[key].keys().has(locale):
			text = store_object.keys[key][locale]

func get_data() -> PackedStringArray:
	return [$KeyEdit.text, $TextEdit.text]

func _set_key(text : String):
	$KeyEdit.text = text
	_last_key = text
	if (store_object):
		_update_data()

func _get_key() -> String:
	return $KeyEdit.text

func _set_text(text : String):
	$TextEdit.text = text

func _get_text() -> String:
	return $TextEdit.text

func _update_store():
	if store_object.keys.keys().has(key) and key != _last_key:
		return
	if store_object.keys.keys().has(_last_key) and (_last_key != key):
		store_object.keys[key] = store_object.keys[_last_key]
		store_object.keys.erase(_last_key)
	else:
		store_object.keys[key] = _last_key_store
	store_object.keys[key][GlobalInfo.current_locale] = text
	_last_key_store = store_object.keys[key]
	_last_key = key

func _check_input():
	if store_object:
		_update_store()

func _on_key_edit_gui_input(event):
	if (event is InputEventMouseButton and 
	event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed()):
		menu_called.emit(self)
