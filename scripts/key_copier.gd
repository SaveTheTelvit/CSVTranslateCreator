extends Node

enum Type {
	NULL = -1,
	KEY = 0,
	OBJECT = 1
}

enum Operation {
	NULL = -1,
	COPY = 0,
	CUT = 1
}

var operation : int = Operation.NULL
var current_element_type : int = Type.NULL
var _name : String = ""
var _key : Dictionary = {}
var _obj : StoreObject = null

func paste_is_possible(to : StoreObject) -> bool:
	match current_element_type:
		Type.KEY:
			if to.keys.has(_name):
				return false
		Type.OBJECT:
			if to.objects.has(_name):
				return false
			if _obj == to || to.is_ancestor(_obj):
				return false
		Type.NULL:
			return false
	return true

func copy(from : StoreObject, element_name : String) -> void:
	current_element_type = Type.NULL
	if from.keys.get(element_name) != null:
		operation = Operation.COPY
		current_element_type = Type.KEY
		_name = element_name
		_key = from.keys.get(element_name)
		return
	elif from.objects.get(element_name) != null:
		current_element_type = Type.OBJECT
		_name = element_name
		_obj = from.objects.get(element_name)
		return

func cut(from : StoreObject, element_name : String) -> void:
	copy(from, element_name)
	match current_element_type:
		Type.KEY:
			from.keys.erase(element_name)
		Type.OBJECT:
			from.objects.erase(element_name)

func paste(to : StoreObject) -> void:
	if !paste_is_possible(to):
		return
	match current_element_type:
		Type.KEY:
			if to.keys.has(_name):
				return
			to.keys[_name] = _key.duplicate(true)
		Type.OBJECT:
			if to.objects.has(_name):
				return
			if _obj == to || to.is_ancestor(_obj):
				return
			_obj.reparent(to)
			to.objects[_name] = _obj.duplicate(true)
