extends ScrollContainer

@onready var key_line : PackedScene = preload("res://scenes/key_line.tscn")
@onready var object_line : PackedScene = preload("res://scenes/object_line.tscn")
@onready var container := $MarginContainer/VBoxContainer

var current_obj : StoreObject = null

var last_line_index : int = -1
var delete_target : Node = null
var target_is_object : bool = false
var always_hide : bool = false

func _to_back():
	if current_obj and current_obj.parent:
		set_store_object(current_obj.parent)

func _ready():
	GlobalInfo.locale_changet.connect(update)
	if !current_obj:
		hide()

func _del_string(obj : Node):
	delete_target = obj
	target_is_object = false
	$PopupMenu.position = get_global_mouse_position()
	$PopupMenu.show()

func _del_obj(obj : Node):
	delete_target = obj
	target_is_object = true
	$PopupMenu.position = get_global_mouse_position()
	$PopupMenu.show()

func clear():
	get_tree().call_group("store_element", "queue_free")
	last_line_index = -1

func update():
	set_store_object(current_obj)

func set_store_object(obj : StoreObject):
	clear()
	if !obj:
		hide()
	else:
		current_obj = obj
		for key in obj.keys:
			var key_line = add_key_line()
			key_line.key = key
		for key in obj.objects.keys():
			var obj_line = add_obj_line()
			obj_line.ref_object = current_obj.objects[key]
			obj_line.key = key
		if !always_hide:
			show()

func add_key_line():
	var key_line_obj = key_line.instantiate()
	container.add_child(key_line_obj)
	last_line_index += 1
	container.move_child(key_line_obj, last_line_index)
	key_line_obj.store_object = current_obj
	key_line_obj.menu_called.connect(_del_string)
	return key_line_obj

func add_obj_line():
	var obj_line_obj = object_line.instantiate()
	container.add_child(obj_line_obj)
	last_line_index += 1
	container.move_child(obj_line_obj, last_line_index)
	obj_line_obj.ref_object = StoreObject.new(current_obj)
	obj_line_obj.switch_object.connect(set_store_object)
	obj_line_obj.menu_called.connect(_del_obj)
	return obj_line_obj

func _on_button_pressed():
	add_key_line()

func _on_button_2_pressed():
	add_obj_line()

func _on_popup_menu_id_pressed(id):
	if delete_target:
		if target_is_object:
			var objects : Dictionary = delete_target.ref_object.parent["objects"]
			objects[delete_target.key].queue_free()
			objects.erase(delete_target.key) 
		else:
			var keys : Dictionary = delete_target.store_object.keys
			keys.erase(delete_target.key)
		delete_target.queue_free()
		delete_target = null
		last_line_index -= 1
