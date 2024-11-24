extends Node

const BG_COLOR : Color = Color("#363d4a")

@onready var save_manager := $SaveManager

var root_object : StoreObject = StoreObject.new()
var file_name : String = ""
var settings_opened = false
var file_dialog_mode = 0
var export_name : String = ""

func _ready():
	RenderingServer.set_default_clear_color(BG_COLOR)
	load_project()
	$Control/HBoxContainer/LeftPanel.to_projects.connect(load_project)
	$Control/HBoxContainer/LeftPanel.export_called.connect(_call_file_dialog)
	$Control/HBoxContainer/LeftPanel.to_back.connect(to_back)
	$Control/HBoxContainer/KeyBox.set_store_object(root_object)
	$Control/HBoxContainer/LeftPanel.switch_scene.connect(_switch_scene)

func _remove_file(file_name : String):
	$SaveManager.delete_project(file_name)

func _export_file(file_name : String):
	export_name = file_name
	file_dialog_mode = 1
	_call_file_dialog()

func _import_file():
	file_dialog_mode = 2
	$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_call_file_dialog()

func _switch_scene():
	settings_opened = true
	$Control/HBoxContainer/KeyBox.always_hide = true
	$Control/HBoxContainer/KeyBox.hide()
	$Control/HBoxContainer/LeftPanel.button_hide(true)
	$Control/HBoxContainer/LocalesSetting.open()

func to_back():
	if !settings_opened:
		$Control/HBoxContainer/KeyBox._to_back()
	else:
		settings_opened = false
		$Control/HBoxContainer/KeyBox.always_hide = false
		$Control/HBoxContainer/KeyBox.show()
		$Control/HBoxContainer/LeftPanel.button_hide(false)
		$Control/HBoxContainer/LocalesSetting.close()

func save_project():
	if file_name.is_empty():
		return
	$SaveManager.save_project(file_name)

func load_project():
	if !(root_object.keys.is_empty() and root_object.objects.is_empty()):
		save_project()
	root_object = StoreObject.new()
	file_name = ""
	$Control.hide()
	$ProjectMenu.show()
	var names : PackedStringArray = $SaveManager.project_names
	$ProjectMenu.call_menu(names)
	$ProjectMenu.remove_file_called.connect(_remove_file)
	$ProjectMenu.export_file_called.connect(_export_file)
	$ProjectMenu.import_file_called.connect(_import_file)
	file_name = await $ProjectMenu.file_name_selected
	$ProjectMenu.remove_file_called.disconnect(_remove_file)
	$ProjectMenu.export_file_called.disconnect(_export_file)
	$ProjectMenu.import_file_called.disconnect(_import_file)
	$ProjectMenu.hide()
	$Control.show()
	if !names.has(file_name):
		names.push_back(file_name)
	$SaveManager.load_project(file_name)

func load(dt : Dictionary):
	var s : String = ""
	var variable = dt.get("root")
	if variable:
		root_object.load(variable)
	variable = dt.get("locales")
	print(variable)
	if variable:
		GlobalInfo.locales = variable
	$Control/HBoxContainer/KeyBox.set_store_object(root_object)

func save() -> Dictionary:
	var dt : Dictionary = {
		"locales" : GlobalInfo.locales,
		"root" : root_object.save()
	}
	return dt

func _call_file_dialog():
	$FileDialog.popup()

func _on_file_dialog_dir_selected(dir):
	match file_dialog_mode:
		0:
			$SaveManager.export_file(dir)
		1:
			$SaveManager.export_project(export_name, dir)
			file_dialog_mode = 0

func _on_file_dialog_file_selected(path):
	match file_dialog_mode:
		2:
			if $SaveManager.import_project(path):
				save_project()
				$ProjectMenu.file_name_selected.emit(file_name)
			$FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			file_dialog_mode = 0
