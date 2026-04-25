extends HBoxContainer

enum FileOptions {NEW, OPEN, SAVE, QUIT}
enum ViewOptions {RESET_CAMERA, GOTO_POINT, TOGGLE_GRID, TOGGLE_AXES, TOGGLE_TARGETS}
enum HelpOptions {BUG, GUIDE, LICENSE, ABOUT}

signal newFile
signal resetCam
signal gotoPoint
signal toggleGrid
signal toggleAxes
signal toggleTargets


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
	
	var popup: PopupMenu = $View.get_popup()
	
	match id:
		ViewOptions.RESET_CAMERA:
			resetCam.emit()
			return
		ViewOptions.GOTO_POINT:
			gotoPoint.emit()
			return
		ViewOptions.TOGGLE_GRID:
			toggleGrid.emit(!popup.is_item_checked(id))
		ViewOptions.TOGGLE_AXES:
			toggleAxes.emit(!popup.is_item_checked(id))
		ViewOptions.TOGGLE_TARGETS:
			Globals.showTargets = !popup.is_item_checked(id)
		
	popup.set_item_checked(id, !popup.is_item_checked(id))


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
