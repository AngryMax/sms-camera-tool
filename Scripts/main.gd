extends Node3D

### Public Vars ###


### Private Vars ##

var _SMSCamera: SMSCameraInterface
var _axis: axisGizmo
var _grid: gridGizmo
var _addFromButton := false	## Tracks when a Keyframe is being added via clicking the Add Keyframe button, or via undoing a deleted keyframe


### Override Funcs ###

func _ready() -> void:
	
	_connectGUISignals()
	_connectToolbarSignals()
	_connectSettingsSignals()
	
	_SMSCamera = %SMSCameraInterface
	_on_new_file()
	
	_grid = gridGizmo.new()
	add_child(_grid.mi)
	_axis = axisGizmo.new()
	add_child(_axis.mi)
	
	Globals.currentKeyframe = %CamKeyframes.get_child(0)	# Since this is in _ready, this *should* always be the first and only keyframe...


func _process(_delta: float) -> void:
	_control()
	_keyboardShortcuts()


### Private Funcs ###

func _connectGUISignals() -> void:
	
	%GUI/%AddPointButton.connect("pressed", _on_add_point_pressed)
	%GUI/%DuplicatePointButton.connect("pressed", _on_duplicate_keyframe_pressed)
	%GUI/%CurPointField.connect("value_changed", _on_cur_keyframe_field_value_changed)
	%GUI/%DeleteButton.connect("pressed", _on_delete_keyframe_pressed)
	%GUI/%Pos.find_child("X").find_child("Input").connect("value_changed", _on_gui_position_changed)
	%GUI/%Pos.find_child("Y").find_child("Input").connect("value_changed", _on_gui_position_changed)
	%GUI/%Pos.find_child("Z").find_child("Input").connect("value_changed", _on_gui_position_changed)
	%GUI/%Target.find_child("X").find_child("Input").connect("value_changed", _on_gui_target_changed)
	%GUI/%Target.find_child("Y").find_child("Input").connect("value_changed", _on_gui_target_changed)
	%GUI/%Target.find_child("Z").find_child("Input").connect("value_changed", _on_gui_target_changed)
	%GUI/%CopyFromGameButton.connect("pressed", _on_copy_all_pressed)
	%GUI/%PreviewPoint.connect("pressed", _on_preview_pressed)
	%GUI/%PlayBackKeyframes.connect("pressed", _on_play_keyframes_pressed)
	%GUI/%TravelTimeInput.connect("value_changed", _on_transition_time_changed)
	%GUI/%EasingOptions.connect("item_selected", _on_ease_direction_changed)
	%GUI/%ViewportOrientation.connect("request_rotate_camera", _on_set_camera_axis)
	
	for button: Button in get_tree().get_nodes_in_group("GrabFromMario"):
		button.toggled.connect(_on_grab_from_target_toggled)
	for button: Button in get_tree().get_nodes_in_group("GrabFromCamera"):
		button.toggled.connect(_on_grab_from_camera_toggled)


func _connectToolbarSignals() -> void:
	%Toolbar.connect("newFile", _on_new_file)
	%Toolbar.connect("resetCam", _on_reset_cam)
	%Toolbar.connect("gotoPoint", _on_goto_point)
	%Toolbar.connect("toggleGrid", _on_toggle_grid)
	%Toolbar.connect("toggleAxes", _on_toggle_axes)
	%Toolbar.connect("save", _on_file_saved)
	%Toolbar/%SaveAsFile.connect("file_selected", _on_file_saved)
	%Toolbar/%OpenFile.connect("file_selected", _on_file_opened)


func _connectSettingsSignals() -> void:
	%Toolbar/%Settings.connect("reloadMat", _on_reload_mat)


func _control() -> void:
	
	if not Input.is_action_pressed("mouse_click_right"):
		#%GUI.process_mode = Node.PROCESS_MODE_ALWAYS
		return
	
	
	#%GUI.process_mode = Node.PROCESS_MODE_DISABLED
	
	var horzInputDir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var vertInputDir := 0.0
	
	if Input.is_action_pressed("move_up"):
		vertInputDir += 1.0
	if Input.is_action_pressed("move_down"):
		vertInputDir -= 1.0
	
	var relativeDir := Vector3(horzInputDir.x, vertInputDir, horzInputDir.y).rotated(Vector3.UP, %Camera3D.rotation.y)
	
	relativeDir /= 2
	
	if Input.is_action_pressed("move_fast"):
		relativeDir *= 2
	
	$Camera3D.position += relativeDir


func _keyboardShortcuts() -> void:
	
	# Toolbar shortcuts
	
	if Input.is_action_just_pressed("shortcut_undo", true):
		Globals.undoRedo.undo()
	
	if Input.is_action_just_pressed("shortcut_redo", true):
		Globals.undoRedo.redo()
	
	if Input.is_action_just_pressed("shortcut_new_file", true):
		_on_new_file()
	
	if Input.is_action_just_pressed("shortcut_open_file", true):
		%Toolbar/%OpenFile.visible = true
	
	if Input.is_action_just_pressed("shortcut_save_as", true):
		%Toolbar/%SaveAsFile.visible = true
	
	if Input.is_action_just_pressed("shortcut_save", true):
		if Globals.curFile == "":
			%Toolbar/%SaveAsFile.visible = true
		else:
			_on_file_saved(Globals.curFile)
	
	
	# Keyframe shortcuts
	
	if Input.is_action_just_pressed("shortcut_new_keyframe", true):
		_on_add_point_pressed()
	
	if Input.is_action_just_pressed("shortcut_delete_keyframe", true):
		_on_delete_keyframe_pressed()
	
	if Input.is_action_just_pressed("shortcut_select_keyframe_next", true):
		var keyframe: CamKeyframe  = _getSpecificKeyframe(1, true)
		keyframe.isSelected = true
		Globals.currentKeyframe = keyframe
	
	if Input.is_action_just_pressed("shortcut_select_keyframe_previous", true):
		var keyframe: CamKeyframe  = _getSpecificKeyframe(-1, true)
		keyframe.isSelected = true
		Globals.currentKeyframe = keyframe
	
	if Input.is_action_just_pressed("shortcut_select_keyframe_first", true):
		var keyframe: CamKeyframe  = _getSpecificKeyframe(0)
		keyframe.isSelected = true
		Globals.currentKeyframe = keyframe
	
	if Input.is_action_just_pressed("shortcut_select_keyframe_last", true):
		var keyframe: CamKeyframe  = _getSpecificKeyframe(-1)
		keyframe.isSelected = true
		Globals.currentKeyframe = keyframe


func _addKeyframe(idx := -1, keyframeVals: SaveFile = null) -> void:
	
	# If _addKeyFrame() is called via redo (ctrl + shift + z)
	if not _addFromButton and Globals.undoRedo.get_current_action_name() == "Add Keyframe":	# TODO: Add Global enum for undoRedo action names, access enum name as string
		_readdKeyframe()
		return
	
	var keyFrame := CamKeyframe.new()
	%CamKeyframes.add_child(keyFrame)
	%CamKeyframes.move_child(keyFrame, idx)
	keyFrame.connect("keyframeChanged", _on_keyframe_changed)
	
	if keyframeVals:
		keyFrame.cameraPoint.position = keyframeVals.positions.front()
		keyFrame.targetPoint.position = keyframeVals.targets.front()
		keyFrame.transitionTime = keyframeVals.times.front()
		keyFrame.easeDirection = keyframeVals.ease.front()
	
	keyFrame.isSelected = true
	Globals.currentKeyframe = keyFrame


## Takes Keyframes "deleted" via ctrl + z (undo) and re-adds them upon ctrl + shift + z (redo)
func _readdKeyframe() -> void:
	var keyframe: CamKeyframe = %DeleteUndoKeyframes.get_child(-1)
	%DeleteUndoKeyframes.remove_child(keyframe)
	%CamKeyframes.add_child(keyframe)
	keyframe.process_mode = Node.PROCESS_MODE_ALWAYS
	keyframe.isSelected = true


func _deleteKeyframe(deleteFromAddUndo := false) -> void:
	
	var keyframesLeft := %CamKeyframes.get_child_count()
	
	var keyframeToDelete: CamKeyframe
	
	if deleteFromAddUndo:	# TODO: The lazy way to handle undos... it works until you can add keyframes at any index or rearrange them lol
		keyframeToDelete = %CamKeyframes.get_child(-1)
	else:
		keyframeToDelete = _getSelectedkeyframe()
	
	#keyframeToDelete.free()
	%CamKeyframes.remove_child(keyframeToDelete)
	%UndoRedoKeyframes.add_child(keyframeToDelete)
	keyframeToDelete.process_mode = Node.PROCESS_MODE_DISABLED
	
	if keyframesLeft > 0:
		var newSelectedKeyframe: CamKeyframe = %CamKeyframes.get_child(0)
		newSelectedKeyframe.isSelected = true
	
	for i in %CamKeyframes.get_child_count():
		var keyframe: CamKeyframe = %CamKeyframes.get_children()[i]
		if keyframe == keyframeToDelete:
			continue
		var updateCamPosLabel = Callable(keyframe.cameraPoint, "updateLabel")	# TODO: just make an updateLable func in CamKeyframe that calls updateLabel in Point?
		var updateTargetLabel = Callable(keyframe.targetPoint, "updateLabel")
		updateCamPosLabel.call_deferred()
		updateTargetLabel.call_deferred()


## "Deletes" added Keyframes via ctrl + z (undo)
func _deleteKeyframeUndo() -> void:
	var keyframe = _getSelectedkeyframe()
	%CamKeyframes.remove_child(keyframe)
	%DeleteUndoKeyframes.add_child(keyframe)
	keyframe.process_mode = Node.PROCESS_MODE_DISABLED


## Re-"creates" deleted Keyframes via ctrl + z (undo)
func _undoDeletedKeyframe():
	var keyframe: CamKeyframe = %UndoRedoKeyframes.get_child(-1)
	%UndoRedoKeyframes.remove_child(keyframe)
	%CamKeyframes.add_child(keyframe)
	keyframe.process_mode = Node.PROCESS_MODE_ALWAYS


## Clears undoRedo's history and clears the Undo Keyframe buffer nodes
func _clearUndoRedoProcess() -> void:
	Globals.undoRedo.clear_history()
	for keyframe in %UndoRedoKeyframes.get_children():
		keyframe.queue_free()
	for keyframe in %DeleteUndoKeyframes.get_children():
		keyframe.queue_free()


## Gets the current selected Keyframe. I probably should use Globals.currentKeyframe in its place?
func _getSelectedkeyframe() -> CamKeyframe:
	
	var returnKeyframe: CamKeyframe
	
	for keyframe: CamKeyframe in %CamKeyframes.get_children():
		if keyframe.isSelected:
			returnKeyframe = keyframe
			break
	
	return returnKeyframe


## Returns a Keyframe at the specified index of %CamKeyframes. [br][br]
## If [b]idxRel[/b] is false, then [b]idx[/b] is the index of the Keyframe you want returned. Negative index numbers count from the back (ie: -1 = last index). [br][br]
## If [b]idxRel[/b] is true, then [b]idx[/b] becomes relative to the index of the Keyframe in Globals.currentKeyframe. [br][br]
## If [b]wrapIdx[/b] is true, then idx wraps around.
func _getSpecificKeyframe(idx: int, idxRel := false, wrapIdx := true) -> CamKeyframe:
	
	var keyframe: CamKeyframe
	var idxNum = %CamKeyframes.get_child_count()
	var desireIdx: int
	
	if idxRel == true:
		idx += Globals.currentKeyframe.get_index()
	
	if wrapIdx:
		desireIdx = wrap(idx, idxNum * -1, idxNum)
	else:
		desireIdx = clamp(idx, 0, idxNum -1)
	keyframe = %CamKeyframes.get_child(desireIdx)
	assert(keyframe != null, "Failed to assign keyframe! Check wrapIdx!")
	
	return keyframe


## Sets the viewport camera above the xy center point of all CamKeyframes
func _setCamera(posArray: Array[Vector3]) -> void:
	
	var avgXZPos := Vector2.ZERO
	var highestY := posArray[0].y
	
	for pointPos in posArray:
		avgXZPos.x += pointPos.x
		avgXZPos.y += pointPos.z
		if pointPos.y > highestY:
			highestY = pointPos.y
	
	avgXZPos /= posArray.size()
	
	%Camera3D.position.x = avgXZPos.x
	%Camera3D.position.y = highestY + 20
	%Camera3D.position.z = avgXZPos.y


func _deleteAllKeyframes() -> void:
	print("deleting all keyframes!")
	for child: Node in %CamKeyframes.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
		%CamKeyframes.remove_child(child)
		child.queue_free()


### GUI Signal Receive Funcs ###

func _on_keyframe_changed(keyframe: CamKeyframe) -> void:
	%GUI.keyframe = keyframe
	Globals.currentKeyframe = keyframe


func _on_add_point_pressed() -> void:
	
	_addFromButton = true
	
	Globals.undoRedo.create_action("Add Keyframe")
	Globals.undoRedo.add_do_method(_addKeyframe)
	Globals.undoRedo.add_undo_method(_deleteKeyframeUndo)
	Globals.undoRedo.commit_action()
	
	_addFromButton = false


func _on_delete_keyframe_pressed() -> void:
	
	var keyframesLeft := %CamKeyframes.get_child_count()
	if keyframesLeft == 1:
		return	# TODO: make this reset the keyframe rather than just do nothing
	
	Globals.undoRedo.create_action("Delete Keyframe")
	Globals.undoRedo.add_do_method(_deleteKeyframe)
	Globals.undoRedo.add_undo_method(_undoDeletedKeyframe.bind())
	Globals.undoRedo.commit_action()


func _on_duplicate_keyframe_pressed() -> void:
	
	var camPos := Globals.currentKeyframe.cameraPoint.position
	var targetPos := Globals.currentKeyframe.targetPoint.position
	var time := Globals.currentKeyframe.transitionTime
	var easing := Globals.currentKeyframe.easeDirection
	
	Globals.undoRedo.create_action("Duplicate Keyframe")
	Globals.undoRedo.add_do_method(_addKeyframe)
	Globals.undoRedo.add_undo_method(_deleteKeyframe.bind(true))
	Globals.undoRedo.commit_action()
	
	var newKeyframe: CamKeyframe = %CamKeyframes.get_child(-1)
	newKeyframe.cameraPoint.position = camPos
	newKeyframe.targetPoint.position = targetPos
	newKeyframe.transitionTime = time
	newKeyframe.easeDirection = easing
	%GUI.keyframe = newKeyframe


func _on_cur_keyframe_field_value_changed(value: float) -> void:
	var idx: int = value - 1
	
	var wasValTyped := false
	if abs(idx - Globals.currentKeyframe.get_index()) > 1:
		wasValTyped = true
	
	var keyframe: CamKeyframe = _getSpecificKeyframe(idx, false, !wasValTyped)
	keyframe.isSelected = true
	%GUI.keyframe = keyframe
	Globals.currentKeyframe = keyframe


func _on_gui_position_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.cameraPoint.setPosition(%GUI.posField)


func _on_gui_target_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.targetPoint.setPosition(%GUI.targetField)


func _on_copy_all_pressed() -> void:
	%GUI.posField = _SMSCamera.position
	%GUI.targetField = _SMSCamera.target


func _on_preview_pressed() -> void:
	_SMSCamera.previewMode = %GUI/%PreviewPoint.button_pressed


func _on_play_keyframes_pressed() -> void:
	_SMSCamera.playbackMode = true


func _on_transition_time_changed(value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.transitionTime = value


func _on_grab_from_target_toggled(_toggle: bool):
	for button: Button in get_tree().get_nodes_in_group("GrabFromMario"):
		if button.button_pressed:
				button.button_pressed = false
				var parent: HBoxContainer = button.get_parent()
				var input: SpinBox = parent.find_child("Input")
				input.value = _SMSCamera.getCoord("getCamTarget" + parent.name)


func _on_grab_from_camera_toggled(_toggle: bool):
		for button: Button in get_tree().get_nodes_in_group("GrabFromCamera"):
			if button.button_pressed:
				button.button_pressed = false
				var parent: HBoxContainer = button.get_parent()
				var input: SpinBox = parent.find_child("Input")
				input.value = _SMSCamera.getCoord("getCamPos" + parent.name)


func _on_ease_direction_changed(value: int) -> void:
	Globals.currentKeyframe.easeDirection = value as Globals.EaseDirection
	%GUI.keyframe = Globals.currentKeyframe


func _on_set_camera_axis(axis: String) -> void:
	match (axis):
		"X+":
			%Camera3D.look_at(%Camera3D.position + Vector3.LEFT)
		"X-":
			%Camera3D.look_at(%Camera3D.position + Vector3.RIGHT)
		"Y+":
			%Camera3D.look_at(%Camera3D.position + Vector3.DOWN)
		"Y-":
			%Camera3D.look_at(%Camera3D.position + Vector3.UP)
		"Z+":
			%Camera3D.look_at(%Camera3D.position + Vector3.FORWARD)
		"Z-":
			%Camera3D.look_at(%Camera3D.position + Vector3.BACK)


### Toolbar Signal Receivers ###

func _on_file_saved(path: String) -> void:
	
	Globals.curFile = path
	
	var saveFile: SaveFile = SaveFile.new()
	
	for i in %CamKeyframes.get_child_count():
		var keyframe: CamKeyframe = %CamKeyframes.get_children()[i]
		saveFile.positions.append(keyframe.cameraPoint.smsPosition)
		saveFile.targets.append(keyframe.targetPoint.smsPosition)
		saveFile.times.append(keyframe.transitionTime)
		saveFile.ease.append(keyframe.easeDirection)
	
	saveFile.saveFile(path)


func _on_file_opened(path: String) -> void:
	
	_clearUndoRedoProcess()
	_deleteAllKeyframes()
	
	(func(): Globals.curFile = path).call_deferred()
	
	var file: SaveFile = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	for i in file.positions.size():
		_addKeyframe()
		var keyframe: CamKeyframe = %CamKeyframes.get_child(i)
		keyframe.cameraPoint.smsPosition = file.positions[i]
		keyframe.targetPoint.smsPosition = file.targets[i]
		keyframe.transitionTime = file.times[i]
		keyframe.easeDirection = file.ease[i]
	
	Globals.currentKeyframe = _getSelectedkeyframe()	# TODO: perhaps just set %GUI.keyframe from Globals.currentKeyframe's setter
	%GUI.keyframe = Globals.currentKeyframe


func _on_new_file() -> void:
	Globals.curFile = ""
	Globals.curFileName = "Untitled"
	_clearUndoRedoProcess()
	_deleteAllKeyframes()
	_addKeyframe()


func _on_reset_cam() -> void:
	%Camera3D.position = Globals.viewportCameraStartPos
	%Camera3D.rotation = Globals.viewportCameraStartRot


func _on_goto_point() -> void:
	
	const POS_OFFSET := Vector3(Vector3.ONE) * 2
	
	var keyframe := Globals.currentKeyframe
	
	for child in keyframe.get_children():
		
		if child is not Point:
			continue
		
		var point: Point = child
		
		$Camera3D.global_position = point.global_position + POS_OFFSET
		$Camera3D.look_at(point.global_position)
		break


func _on_toggle_grid(toggle: bool) -> void:
	_grid.toggleVisible(toggle)


func _on_toggle_axes(toggle: bool) -> void:
	_axis.toggleVisible(toggle)



### Settings Signal Receive Funcs ###

func _on_reload_mat(enable_shaders: bool) -> void:	# TODO: if more shader materials get added, make a dictionary with refs and for loop thru it
	
	var camShaderMatOverride: ShaderMaterial = load("res://Scenes/Mat/camera_model_shader_mat.tres")
	var targetShaderMatOverride: ShaderMaterial = load("res://Scenes/Mat/target_model_shader_mat.tres")
	
	var targetMesh: MeshInstance3D = %SMSCameraRepresantation/TargetModel
	var camMesh: MeshInstance3D = %SMSCameraRepresantation/CamModel/body
	
	targetMesh.set_surface_override_material(0, null)
	camMesh.set_surface_override_material(0, null)
	if enable_shaders == true:
		print("enable shaders")
		targetMesh.material_override = targetShaderMatOverride
		camMesh.material_override = camShaderMatOverride
	else:
		print("disable shaders")
		targetMesh.material_override = null
		camMesh.material_override = null
	
