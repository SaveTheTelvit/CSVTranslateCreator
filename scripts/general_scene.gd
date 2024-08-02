extends Node

const BG_COLOR : Color = Color("#363d4a")

@onready var save_manager := $SaveManager

var root_object : StoreObject = StoreObject.new()
var file_name : String = ""
var settings_opened = false

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
	var paths : PackedStringArray = $SaveManager.project_names
	$ProjectMenu.call_menu(paths)
	$ProjectMenu.remove_file_called.connect(_remove_file)
	print(root_object.keys, " filename: ", file_name)
	file_name = await $ProjectMenu.file_name_selected
	$ProjectMenu.remove_file_called.disconnect(_remove_file)
	$ProjectMenu.hide()
	$Control.show()
	if !paths.has(file_name):
		paths.push_back(file_name)
	$SaveManager.load_project(file_name)

func load(dt : Dictionary):
	var s : String = ""
	var variable = dt.get("root")
	if variable:
		root_object.load(variable)
	variable = dt.get("locales")
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
	$SaveManager.export_file(dir)
