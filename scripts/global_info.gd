extends Node

signal locale_changet()
signal locales_arr_changet()

var locales : PackedStringArray = ["en"] : set = _set_locales
var current_locale : String = "en" : set = _set_current_locale
var prepare: String = "_"

func _set_current_locale(locale : String):
	current_locale = locale
	locale_changet.emit()

func remove_locale(locale : String):
	if locales.has(locale):
		if current_locale == locale:
			current_locale = locales[locales.find(locale) + 1]
		locales.remove_at(locales.find(locale))
		locales_arr_changet.emit()

func add_locale(locale : String):
	if !locales.has(locale):
		locales.push_back(locale)
		locales_arr_changet.emit()

func _set_locales(locals : PackedStringArray):
	if locals.size() == 0:
		locales = ["en"]
	else:
		locales = locals
	if locales.find(current_locale) == -1:
		current_locale = locales[0]
	locales_arr_changet.emit()
