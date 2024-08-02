class_name StoreObject extends Node

var keys : Dictionary = {}
var objects : Dictionary = {}
var parent : StoreObject

func _init(_parent : StoreObject = null):
	parent = _parent

func add_key(key : String, value : String, locale : String):
	if keys.get(key):
		keys[key][locale] = value
	else: 
		var dt : Dictionary = {}
		dt[locale] = value
		keys[key] = dt

func add_object(key : String, obj : StoreObject):
	if obj:
		objects[key] = obj

func save() -> Dictionary:
	var dt : Dictionary = {}
	for key in keys.keys():
		if key.is_empty():
			continue
		dt[key] = keys[key]
	var tmp_obj : Dictionary = {}
	for key in objects.keys():
		if key.is_empty():
			continue
		tmp_obj[key] = objects[key].save()
	dt["objects"] = tmp_obj
	return dt

func load(dt : Dictionary):
	for key in dt.keys():
		if key == "objects":
			var objects_ref : Dictionary = dt[key]
			for i_key in objects_ref.keys():
				objects_ref[i_key]
				var obj = StoreObject.new(self)
				obj.load(objects_ref[i_key])
				objects[i_key] = obj
		else:
			keys[key] = dt[key]
