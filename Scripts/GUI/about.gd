extends Popup

func _ready() -> void:
	
	var text: String = %Text.text
	
	%Text.text = text.replace("[you_shouldnt_see_this]", ProjectSettings.get_setting("application/config/version"))

func _on_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
