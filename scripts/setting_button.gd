extends TextureRect

const DF_MODULATION : Color = Color("#00000046")
const HOVER_MODULATION : Color = Color("#ffffff46")
const PRESS_MODULATION : Color = Color("#0000008c")

var pressed : bool = false
var mouse_enter : bool = false

func _update_modulation() -> void:
	if mouse_enter:
		if pressed:
			self_modulate = PRESS_MODULATION
		else:
			self_modulate = HOVER_MODULATION
	else:
		self_modulate = DF_MODULATION

func _notification(what) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		mouse_enter = true
		_update_modulation()
	elif what == NOTIFICATION_MOUSE_EXIT:
		mouse_enter = false
		_update_modulation()

func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			pressed = true
		else:
			pressed = false
		_update_modulation()
