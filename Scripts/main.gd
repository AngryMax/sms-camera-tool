extends Node3D

### Public Vars ###


### Private Vars ##

var _SMSCamera: SMSCameraInterface
var GDInterface: Node
var _axis: axisGizmo
var _grid: gridGizmo

### Override Funcs ###

func _ready() -> void:
	_connectGUISignals()
	_SMSCamera = %SMSCameraInterface
	_addPoint()
	
	_axis = axisGizmo.new()
	add_child(_axis.mi)
	# TODO: call _axis.toggleVisible() using the toolbar view menu
	
	_grid = gridGizmo.new()
	add_child(_grid.mi)

func _process(_delta: float) -> void:
	_control()


### Private Funcs ###

func _connectGUISignals() -> void:
	%GUI/%AddPointButton.connect("pressed", _on_add_point_pressed)
	%GUI/%DuplicatePointButton.connect("pressed", _on_duplicate_point_pressed)
	%GUI/%CurPointField.connect("value_changed", _on_cur_keyframe_field_value_changed)
	%GUI/%PlayBackKeyframes.connect("pressed", _on_replay_points_pressed)
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

func _control() -> void:
	
	#if not Input.is_action_pressed("mouse_click_right"):
		#return
	
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


func _getSelectedkeyframe() -> CamKeyframe:
	
	var returnKeyframe: CamKeyframe
	
	for keyframe: CamKeyframe in %CamKeyframes.get_children():
		if keyframe.isSelected:
			returnKeyframe = keyframe
			break
	
	_SMSCamera.selectedKeyframe = returnKeyframe	# Kinda messy but it works
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


### Signal Receive Funcs ###

func _on_keyframe_changed(keyframe: CamKeyframe) -> void:
	%GUI.keyframe = keyframe


func _on_add_point_pressed() -> void:
	_addPoint()


func _on_delete_point_pressed() -> void:
	
	var keyframesLeft := %CamKeyframes.get_child_count()
	
	if keyframesLeft == 1:
		return	# TODO: make this reset the keyframe rather than just do nothing
	
	var keyframe := _getSelectedkeyframe()
	keyframe.delete()
	
	%GUI.maxKeyframes = keyframesLeft
	
	if keyframesLeft > 0:
		var newSelectedKeyframe: CamKeyframe = %CamKeyframes.get_child(0)
		newSelectedKeyframe.isSelected = true


func _on_duplicate_point_pressed() -> void:	# TODO: make this actually work
	
	#var kfToCopy := _getSelectedkeyframe()
	#_addPoint()
	#
	#var kfToPaste := _getSelectedkeyframe()
	#
	#kfToPaste = kfToCopy
	
	print("duplicate")


func _on_cur_keyframe_field_value_changed(value: float) -> void:
	var idx: int = value - 1
	var keyframe: CamKeyframe = %CamKeyframes.get_child(idx)
	keyframe.isSelected = true
	%GUI.keyframe = keyframe


func _on_replay_points_pressed() -> void:
	print("replay")


func _on_gui_position_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.cameraPoint.smsPosition = %GUI.posField


func _on_gui_target_changed(_value: float) -> void:
	var keyframe := _getSelectedkeyframe()
	keyframe.targetPoint.smsPosition = %GUI.targetField
	%Camera3D.position = keyframe.cameraPoint.position


func _on_copy_all_pressed() -> void:
	%GUI.posField = _SMSCamera.position
	%GUI.targetField = _SMSCamera.target


func _on_preview_pressed() -> void:
	_SMSCamera.previewMode = %GUI/%PreviewPoint.button_pressed


func _on_play_keyframes_pressed() -> void:
	_SMSCamera.playbackMode = true
