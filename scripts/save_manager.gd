extends Node

var project_names : PackedStringArray = []

func _ready():
	load_data()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_parent().save_project()
		save_data()

func save_project(filename : String):
	if !project_names.has(filename):
		project_names.push_back(filename)
	var save_file : FileAccess = FileAccess.open("user://" + filename + ".csv_prepare", FileAccess.WRITE)
	if get_parent() and get_parent().has_method("save"):
		save_file.store_line(JSON.stringify(get_parent().save()))

func load_project(filename : String):
	if !FileAccess.file_exists("user://" + filename + ".csv_prepare"):
		save_project(filename)
	var save_file := FileAccess.open("user://" + filename + ".csv_prepare", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json := JSON.new()
		if json.parse(save_file.get_line()) == OK:
			if get_parent() and get_parent().has_method("load"):
				get_parent().load(json.get_data())

func delete_project(file_name : String):
	DirAccess.remove_absolute("user://" + file_name + ".csv_prepare")
	project_names.remove_at(project_names.find(file_name))

func export_project(file_name : String, dir : String):
	if !project_names.has(file_name):
		return
	if !DirAccess.dir_exists_absolute(dir):
		return
	load_project(file_name)
	var export_file : FileAccess = FileAccess.open(dir + "/" + file_name + ".csv_prepare", FileAccess.WRITE)
	if get_parent() and get_parent().has_method("save"):
		export_file.store_line(JSON.stringify(get_parent().save()))

func import_project(path : String) -> bool:
	var file_name : String = path.get_file()
	file_name = file_name.erase(
		file_name.length() - file_name.get_extension().length() - 1, 
		file_name.get_extension().length() + 1
	)
	if project_names.has(file_name):
		return false
	if !FileAccess.file_exists(path):
		return false
	if path.get_extension() != "csv_prepare":
		return false
	var save_file := FileAccess.open(path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json := JSON.new()
		if json.parse(save_file.get_line()) == OK:
			if get_parent() and get_parent().has_method("load"):
				get_parent().load(json.get_data())
				get_parent().file_name = file_name
	return true

func save_data():
	var save_file : FileAccess = FileAccess.open("user://paths.data", FileAccess.WRITE)
	if project_names.size():
		save_file.store_csv_line(project_names)

func load_data():
	var save_file : FileAccess = FileAccess.open("user://paths.data", FileAccess.READ)
	if !save_file:
		return
	project_names = save_file.get_csv_line()
	for i in range(project_names.size() - 1, -1 , -1):
		if project_names[i].is_empty():
			project_names.remove_at(i)

func get_keys_in_obj(object : StoreObject, prepare_string : String = "") -> Array[PackedStringArray]:
	var array : Array[PackedStringArray] = []
	for i in object.keys.size():
		var key = object.keys.keys()[i]
		var line : PackedStringArray = [prepare_string + key]
		for locale in GlobalInfo.locales:
			line.push_back(object.keys[key].get(locale, ""))
		array.push_back(line)
	for key in object.objects.keys():
		for line in get_keys_in_obj(object.objects[key], prepare_string + key + "_"):
			array.push_back(line)
	return array

func export_file(dir : String):
	var root_objet : StoreObject = get_parent().root_object
	if !root_objet:
		return
	var first_line : PackedStringArray = GlobalInfo.locales.duplicate()
	if !first_line.size():
		return
	var save_file : FileAccess = FileAccess.open(dir + "/" + get_parent().file_name + ".csv", FileAccess.WRITE)
	first_line.insert(0, "keys")
	save_file.store_csv_line(first_line)
	for line in get_keys_in_obj(root_objet):
		save_file.store_csv_line(line)
