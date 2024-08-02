extends Panel

signal to_back()
signal switch_scene()
signal export_called()
signal to_projects()

@onready var menu_button : MenuButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuButton
@onready var popup_menu : PopupMenu = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/MenuButton.get_popup()

func button_hide(mode : bool):
	if mode:
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer.hide()
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer.show()

func _ready():
	GlobalInfo.locales_arr_changet.connect(setup_popup)
	GlobalInfo.locale_changet.connect(_on_current_locale_changet)
	menu_button.text = GlobalInfo.current_locale.to_upper()
	popup_menu.index_pressed.connect(_on_menu_button_pressed)
	setup_popup()

func setup_popup():
	popup_menu.clear()
	for locale in GlobalInfo.locales:
		popup_menu.add_item(locale)
	popup_menu.add_item("Редактировать")

func _on_current_locale_changet():
	menu_button.text = GlobalInfo.current_locale.to_upper()

func _on_menu_button_pressed(index : int):
	if index == popup_menu.item_count - 1:
		switch_scene.emit()
		return
	GlobalInfo.current_locale = popup_menu.get_item_text(index).to_lower()
	
func _on_button_pressed():
	to_back.emit()

func _on_button_2_pressed():
	export_called.emit()

func _on_proj_button_pressed():
	to_projects.emit()
