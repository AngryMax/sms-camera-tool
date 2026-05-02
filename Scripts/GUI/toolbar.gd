extends HBoxContainer

enum FileOptions {NEW, OPEN, SAVE_AS, QUIT, SAVE}
enum EditOptions {UNDO, REDO, SETTINGS}
enum ToolsOptions {TOGGLE_SNAP, TOGGLE_CAM_FOLLOW, TOGGLE_TARGET_FOLLOW}
enum ViewOptions {TOGGLE_GRID, TOGGLE_AXES, TOGGLE_TARGETS, RESET_CAMERA, GOTO_POINT}
enum HelpOptions {BUG, GUIDE, LICENSE, ABOUT}

var _isPopupVisible := false	# NOTE: Be highly suspicious of this if any bug relating to keyboard shortcuts arises...

signal newFile
signal resetCam
signal gotoPoint
signal toggleGrid
signal toggleAxes
signal save
signal isPopupWindow


func _ready() -> void:
	%File.get_popup().id_pressed.connect(_on_file_menu)
	%Edit.get_popup().id_pressed.connect(_on_edit_menu)
	%Tools.get_popup().id_pressed.connect(_on_tools_menu)
	%View.get_popup().id_pressed.connect(_on_view_menu)
	%Help.get_popup().id_pressed.connect(_on_help_menu)
	
	%OpenFile.use_native_dialog = true
	%SaveAsFile.use_native_dialog = true
	
	_checkForPopupOrFileDialogChildAndConnect()

## Worlds most verbose function name lol. Recursively connects all Popup and FileDialog
## visiblity_changed signals in the Toolbar.tscn tree to _on_popup_visibility_changed()
func _checkForPopupOrFileDialogChildAndConnect(node: Node = self) -> void:
	
	for child in node.get_children():
		if child is Popup or child is FileDialog:
			if child.get_parent() is Popup or child.get_parent() is FileDialog:	# don't connect signal or check children of child if parent was already connected
				continue
			child.connect("visibility_changed", _on_popup_visibility_changed)
		
		_checkForPopupOrFileDialogChildAndConnect(child)

func _on_file_menu(id: int) -> void:
	
	match id:
		FileOptions.NEW:
			newFile.emit()
		FileOptions.OPEN:
			%OpenFile.visible = true
		FileOptions.SAVE_AS:
			%SaveAsFile.visible = true
		FileOptions.QUIT:
			get_tree().quit()
		FileOptions.SAVE:
			save.emit()
		_:
			push_error("Invalid File menu button!")


func _on_edit_menu(id: int) -> void:
	
	match id:
		EditOptions.UNDO:
			Globals.undoRedo.undo()
		EditOptions.REDO:
			Globals.undoRedo.redo()
		EditOptions.SETTINGS:
			%Settings.visible = true
		_:
			push_error("Invalid Edit menu button!")


func _on_tools_menu(id: int) -> void:
	
	var popup: PopupMenu = %Tools.get_popup()
	var isSnap := false
	
	match id:
		ToolsOptions.TOGGLE_SNAP:
			isSnap = !popup.is_item_checked(id)
		ToolsOptions.TOGGLE_CAM_FOLLOW:
			Globals.camPointFollowViewport = !popup.is_item_checked(id)
		ToolsOptions.TOGGLE_TARGET_FOLLOW:
			Globals.targetPointFollowViewport = !popup.is_item_checked(id)
		_:
			push_error("Invalid Tools menu button!")
	
	popup.set_item_checked(id, !popup.is_item_checked(id))
	
	if not isSnap:
		Globals.snapMode = Globals.SnapMode.NONE
		return
	
	if isSnap:	# TODO: make this "if snapMode == POINT" then have "if snapMode == GRID"
		Globals.snapMode = Globals.SnapMode.POINT


func _on_view_menu(id: int) -> void:
	
	var popup: PopupMenu = $View.get_popup()
	
	match id:
		ViewOptions.TOGGLE_GRID:
			toggleGrid.emit(!popup.is_item_checked(id))
		ViewOptions.TOGGLE_AXES:
			toggleAxes.emit(!popup.is_item_checked(id))
		ViewOptions.TOGGLE_TARGETS:
			Globals.showTargets = !popup.is_item_checked(id)
		ViewOptions.RESET_CAMERA:
			resetCam.emit()
			return
		ViewOptions.GOTO_POINT:
			gotoPoint.emit()
			return
		_:
			push_error("Invalid View menu button!")
			return
	
	popup.set_item_checked(id, !popup.is_item_checked(id))


func _on_help_menu(id: int) -> void:
	
	match id:
		HelpOptions.BUG:
			%"Website Prompt".setWebsiteString("https://github.com/AngryMax/sms-camera-tool/issues")
		HelpOptions.GUIDE:
			%"Website Prompt".setWebsiteString("https://github.com/AngryMax/sms-camera-tool/tree/dev#sms-camera-tool")
		HelpOptions.LICENSE:
			%"Website Prompt".setWebsiteString("https://github.com/AngryMax/sms-camera-tool/blob/main/LICENSE")
		HelpOptions.ABOUT:
			%About.visible = true
			return
		_:
			push_error("Invalid Help menu button!")
			return
	
	%"Website Prompt".show()


func _on_popup_visibility_changed() -> void:
	print(_isPopupVisible)
	isPopupWindow.emit(_isPopupVisible)
	_isPopupVisible = not _isPopupVisible
