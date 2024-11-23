extends HBoxContainer

signal switch_object(obj : StoreObject)
signal menu_called(obj : Node)

var _last_key : String = ""
var key : set = _set_key, get = _get_key
var ref_object : StoreObject = null

func get_parent_obj() -> StoreObject:
	return ref_object.parent

func _set_key(text : String):
	$KeyEdit.text = text
	_last_key = text
	$Button.disabled = false

func _get_key() -> String:
	return $KeyEdit.text

func _on_button_pressed():
	if ref_object:
		switch_object.emit(ref_object)

func _on_key_edit_text_changed():
	if ref_object.parent.objects.keys().has(key) and key != _last_key:
		return
	if !key.is_empty():
		if $Button.disabled:
			$Button.disabled = false
	elif !$Button.disabled:
		$Button.disabled = true
	if ref_object.parent.objects.keys().has(_last_key) and (_last_key != key):
		ref_object.parent.objects[key] = ref_object.parent.objects[_last_key]
		ref_object.parent.objects.erase(_last_key)
	else:
		ref_object.parent.objects[key] = ref_object
	_last_key = key

func _on_key_edit_gui_input(event):
	if (event is InputEventMouseButton and 
	event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed()):
		menu_called.emit(self)
