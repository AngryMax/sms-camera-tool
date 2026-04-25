extends HBoxContainer

enum FileOptions {NEW, OPEN, SAVE, QUIT}
enum HelpOptions {BUG, GUIDE, LICENSE, ABOUT}
enum ViewOptions {temp}


func _ready() -> void:
	%File.get_popup().id_pressed.connect(_on_file_menu)
	%Help.get_popup().id_pressed.connect(_on_help_menu)


func _on_file_menu(id: int) -> void:
	
	match id:
		FileOptions.NEW:
			pass
		FileOptions.OPEN:
			%OpenFile.visible = true
		FileOptions.SAVE:
			%SaveAsFile.visible = true
		FileOptions.QUIT:
			get_tree().quit()
		_:
			push_error("Invalid File menu button!")


func _on_help_menu(id: int) -> void:
	
	match id:
		HelpOptions.BUG:
			pass
		HelpOptions.GUIDE:
			pass
		HelpOptions.LICENSE:
			pass
		HelpOptions.ABOUT:
			%About.visible = true
