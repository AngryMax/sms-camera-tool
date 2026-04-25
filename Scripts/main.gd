extends Node3D

### Public Vars ###


### Private Vars ##

var _SMSCamera: SMSCameraInterface
var _axis: axisGizmo
var _grid: gridGizmo

### Override Funcs ###

func _ready() -> void:
	
	_connectGUISignals()
	_connectToolbarSignals()
	_SMSCamera = %SMSCameraInterface
	_addPoint()
	
	_grid = gridGizmo.new()
	add_child(_grid.mi)
	_axis = axisGizmo.new()
	add_child(_axis.mi)
	
	Globals.currentKeyframe = %CamKeyframes.get_child(0)	# Since this is in _ready, this *should* always be the first and only keyframe...


func _process(_delta: float) -> void:
	_control()


### Private Funcs ###

func _connectGUISignals() -> void:
	
	%GUI/%AddPointButton.connect("pressed", _on_add_point_pressed)
	%GUI/%DuplicatePointButton.connect("pressed", _on_duplicate_point_pressed)
	%GUI/%CurPointField.connect("value_changed", _on_cur_keyframe_field_value_changed)
	%GUI/%DeleteButton.connect("pressed", _on_delete_point_pressed)
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
	%Toolbar/%SaveAsFile.connect("file_selected", _on_file_saved)
	%Toolbar/%OpenFile.connect("file_selected", _on_file_opened)


func _control() -> void:
	
	if not Input.is_action_pressed("mouse_click_right"):
		return
	
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


func _addPoint() -> void:
	var camKeyFrame := CamKeyframe.new()
	%CamKeyframes.add_child(camKeyFrame)
	%GUI.maxKeyframes = %CamKeyframes.get_child_count()
	camKeyFrame.connect("keyframeChanged", _on_keyframe_changed)
	camKeyFrame.isSelected = true
	Globals.currentKeyframe = camKeyFrame


func _getSelectedkeyframe() -> CamKeyframe:
	
	var returnKeyframe: CamKeyframe
	
	for keyframe: CamKeyframe in %CamKeyframes.get_children():
		if keyframe.isSelected:
			returnKeyframe = keyframe
			break
	
	return returnKeyframe


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
	for child: Node in %CamKeyframes.get_children():
		%CamKeyframes.remove_child(child)
		child.queue_free()


### GUI Signal Receive Funcs ###

func _on_keyframe_changed(keyframe: CamKeyframe) -> void:
	%GUI.keyframe = keyframe
	Globals.currentKeyframe = keyframe


func _on_add_point_pressed() -> void:
	_addPoint()


func _on_delete_point_pressed() -> void:
	
	var keyframesLeft := %CamKeyframes.get_child_count()
	
	if keyframesLeft == 1:
		return	# TODO: make this reset the keyframe rather than just do nothing
	
	var keyframeToDelete := _getSelectedkeyframe()
	keyframeToDelete.free()
	
	%GUI.maxKeyframes = keyframesLeft
	
	if keyframesLeft > 0:
		var newSelectedKeyframe: CamKeyframe = %CamKeyframes.get_child(0)
		newSelectedKeyframe.isSelected = true
	
	
	for i in %CamKeyframes.get_child_count():
		var keyframe: CamKeyframe = %CamKeyframes.get_children()[i]
		if keyframe == keyframeToDelete:
			continue
		var updateCamPosLabel = Callable(keyframe.cameraPoint, "updateLabel")
		var updateTargetLabel = Callable(keyframe.targetPoint, "updateLabel")
		updateCamPosLabel.call_deferred()
		updateTargetLabel.call_deferred()


func _on_duplicate_point_pressed() -> void:
	
	var camPos := Globals.currentKeyframe.cameraPoint.position
	var targetPos := Globals.currentKeyframe.targetPoint.position
	var time := Globals.currentKeyframe.transitionTime
	var interps := Globals.currentKeyframe.interpolation
	
	_addPoint()
	
	var newKeyframe: CamKeyframe = %CamKeyframes.get_child(-1)
	newKeyframe.cameraPoint.position = camPos
	newKeyframe.targetPoint.position = targetPos
	newKeyframe.transitionTime = time
	newKeyframe.interpolation = interps
	%GUI.keyframe = newKeyframe


func _on_cur_keyframe_field_value_changed(value: float) -> void:
	var idx: int = value - 1
	var keyframe: CamKeyframe = %CamKeyframes.get_child(idx)
	keyframe.isSelected = true
	%GUI.keyframe = keyframe
	Globals.currentKeyframe = keyframe


func _on_gui_position_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.cameraPoint.smsPosition = %GUI.posField


func _on_gui_target_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.targetPoint.smsPosition = %GUI.targetField
	#%Camera3D.position = keyframe.cameraPoint.position


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


### Toolbar Signal Receivers ###

func _on_file_saved(path: String):
	
	var saveFile: SaveFile = SaveFile.new()
	
	for i in %CamKeyframes.get_child_count():
		var keyframe: CamKeyframe = %CamKeyframes.get_children()[i]
		saveFile.positions.append(keyframe.cameraPoint.smsPosition)
		saveFile.targets.append(keyframe.targetPoint.smsPosition)
		saveFile.times.append(keyframe.transitionTime)
		saveFile.interps.append(keyframe.interpolation)
	
	saveFile.saveFile(path)


func _on_file_opened(path: String):
	
	var file: SaveFile = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	_deleteAllKeyframes()
	
	for i in file.positions.size():
		_addPoint()
		var keyframe: CamKeyframe = %CamKeyframes.get_child(i)
		keyframe.cameraPoint.smsPosition = file.positions[i]
		keyframe.targetPoint.smsPosition = file.targets[i]
		keyframe.transitionTime = file.times[i]
		keyframe.interpolation = file.interps[i]
	
	Globals.currentKeyframe = _getSelectedkeyframe()	# TODO: perhaps just set %GUI.keyframe from Globals.currentKeyframe's setter
	%GUI.keyframe = Globals.currentKeyframe


func _on_new_file():
	_deleteAllKeyframes()
	_addPoint()


func _on_reset_cam():
	%Camera3D.position = Globals.viewportCameraStartPos
	%Camera3D.rotation = Globals.viewportCameraStartRot


func _on_goto_point():
	
	const POS_OFFSET := Vector3(Vector3.ONE) * 2
	
	var keyframe := Globals.currentKeyframe
	
	for child in keyframe.get_children():
		
		if child is not Point:
			continue
		
		var point: Point = child
		
		$Camera3D.global_position = point.global_position + POS_OFFSET
		$Camera3D.look_at(point.global_position)
		break


func _on_toggle_grid(toggle: bool):
	_grid.toggleVisible(toggle)


func _on_toggle_axes(toggle: bool):
	_axis.toggleVisible(toggle)
