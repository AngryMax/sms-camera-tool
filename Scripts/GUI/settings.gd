extends PopupPanel

signal reloadMat

func _on_shader_setting_toggled(toggled_on: bool) -> void:
	reloadMat.emit(toggled_on)
