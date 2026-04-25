extends HBoxContainer

enum FileOptions {NEW, OPEN, SAVE, QUIT}
enum ViewOptions {RESET_CAMERA, GOTO_POINT, TOGGLE_GRID, TOGGLE_AXES, TOGGLE_TARGETS}
enum HelpOptions {BUG, GUIDE, LICENSE, ABOUT}

signal newFile
signal resetCam


func _ready() -> void:
	%File.get_popup().id_pressed.connect(_on_file_menu)
	%View.get_popup().id_pressed.connect(_on_view_menu)
	%Help.get_popup().id_pressed.connect(_on_help_menu)


func _on_file_menu(id: int) -> void:
	
	match id:
		FileOptions.NEW:
			newFile.emit()
		FileOptions.OPEN:
			%OpenFile.visible = true
		FileOptions.SAVE:
			%SaveAsFile.visible = true
		FileOptions.QUIT:
			get_tree().quit()
		_:
			push_error("Invalid File menu button!")


func _on_view_menu(id: int) -> void:
	
	match id:
		ViewOptions.RESET_CAMERA:
			resetCam.emit()
		ViewOptions.GOTO_POINT:
			pass
		ViewOptions.TOGGLE_GRID:
			pass
		ViewOptions.TOGGLE_AXES:
			pass
		ViewOptions.TOGGLE_TARGETS:
			pass


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
