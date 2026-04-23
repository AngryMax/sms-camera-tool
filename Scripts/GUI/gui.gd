extends Control

var GDInterface: Node

var pointArray: Array[SMSCamPoint]
var pointNum: int	## The number of points

var lockApply := false	## Keeps settings from being applied
var previewMode := false
var linkTransforms := false


func _ready() -> void:
	GDInterface = %GDInterface
	GDInterface.Hook()
	addPoint()
	
	# TODO: this is VERY bad practice, this needs to be refactored asap!!!!!!! That probably beings with making pointArray belong to the parent...
	get_parent().find_child("Toolbar").find_child("File").get_popup().id_pressed.connect(_on_file_menu)
	get_parent().find_child("Toolbar").find_child("Help").get_popup().id_pressed.connect(_on_help_menu)
	get_parent().find_child("Toolbar").find_child("View").get_popup().id_pressed.connect(_on_view_menu)
	
	for button: Button in get_tree().get_nodes_in_group("GrabFromMario"):
		button.toggled.connect(_on_grab_from_target_toggled)
	for button: Button in get_tree().get_nodes_in_group("GrabFromCamera"):
		button.toggled.connect(_on_grab_from_camera_toggled)
	


func _process(_delta: float) -> void:
	
	previewPoint()


func replayPoints():
	
	%PreviewPoint.button_pressed = false
	%PreviewPoint.emit_signal("pressed")
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(pointArray.front().position, pointArray.front().target)
	await get_tree().create_timer(0.5).timeout
	print(pointArray.size())
	
	for i in pointNum:
		
		var fromPos: Vector3 = pointArray[i].position
		var curPos := fromPos
		var toPos: Vector3
		var fromTarget: Vector3 = pointArray[i].target
		var curTarget := fromTarget
		var toTarget: Vector3
		
		if i == pointNum - 1:		# If we're on the last point
			toPos = pointArray.back().position
			toTarget = pointArray.back().target
		else:
			toPos = pointArray[i + 1].position
			toTarget = pointArray[i + 1].target
		
		var startTime: float = Time.get_ticks_msec() / 1000.0
		
		print("Processing point ", i)
		print("Currently at ", curPos)
		print("Currently looking at ", curTarget)
		print("Going to ", toPos)
		print("Going to look at ", toTarget)
		
		var lastTime := 0.0
		while true:
			
			var curTime: float = Time.get_ticks_msec() / 1000.0
			
			if curTime - lastTime <= 1.0 / 60.0:	# Bootleg 60 ticks per second system
				continue
			
			lastTime = curTime
			
			var lerpPow: = curTime - startTime
			lerpPow /= pointArray[i].transitionTime
			if lerpPow >= 1.0:
				lerpPow = 1.0
			
			match pointArray[i].interpolation:
				SMSCamPoint.InterpolationTypes.Linear:
					curPos = interpolateLinear(fromPos, toPos, lerpPow)
					curTarget = interpolateLinear(fromTarget, toTarget, lerpPow)
				SMSCamPoint.InterpolationTypes.Cubic:
					curPos = interpolateSmooth(fromPos, toPos, lerpPow)
					curTarget = interpolateSmooth(fromTarget, toTarget, lerpPow)
				_:
					print("uh oh")
					push_error("Invalid interpolation type!")
			
			GDInterface.writeCamData(curPos, curTarget)
			
			if lerpPow >= 1.0:
				break


func interpolateLinear(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	return from.lerp(to, lerpPow)


func interpolateCubic(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:	# TODO: actually figure this out lol
	return from.cubic_interpolate(to, to * 1.5, to * 0.75, lerpPow)


func interpolateSmooth(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	lerpPow = smoothstep(0, 1, lerpPow)
	return from.lerp(to, lerpPow)


var lastState := false	# TODO: make a real state machine... sigh
func previewPoint():
	
	if lastState == true and previewMode == false:
		GDInterface.restoreCameraCode()
		lastState = false
	
	if not previewMode:
		return
	
	lastState = true
	
	var curPoint: int = %CurPointField.value
	curPoint -= 1
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(pointArray[curPoint].position, pointArray[curPoint].target)


func resetPoints():
	pointArray.clear()
	pointNum = 0
	addPoint()
	updatePointEdit(0)
	applyPointChanges()


## Updates all the GUI values to the selected point
func updatePointEdit(point: int):
	
	lockApply = true
	
	point -= 1
	
	%Pos.find_child("X").find_child("Input").value = pointArray[point].position.x
	%Pos.find_child("Y").find_child("Input").value = pointArray[point].position.y
	%Pos.find_child("Z").find_child("Input").value = pointArray[point].position.z
	
	%Target.find_child("X").find_child("Input").value = pointArray[point].target.x
	%Target.find_child("Y").find_child("Input").value = pointArray[point].target.y
	%Target.find_child("Z").find_child("Input").value = pointArray[point].target.z
	
	lockApply = false
	
	%TravelTimeInput.value = pointArray[point].transitionTime
	
	%InterpolationOption.selected = pointArray[point].interpolation


## Sets backend values from what's been entered in the GUI
func applyPointChanges():
	
	if lockApply:
		return
	
	var point = %CurPointField.value - 1
	
	pointArray[point].position = Vector3(%Pos.find_child("X").find_child("Input").value, 
										 %Pos.find_child("Y").find_child("Input").value,
										 %Pos.find_child("Z").find_child("Input").value)
							
	pointArray[point].target = Vector3(%Target.find_child("X").find_child("Input").value,
									   %Target.find_child("Y").find_child("Input").value,
									   %Target.find_child("Z").find_child("Input").value)
	
	pointArray[point].transitionTime = %TravelTimeInput.value
	
	pointArray[point].interpolation = %InterpolationOption.selected


func grabFromCam():
	
	%Pos.find_child("X").find_child("Input").value = GDInterface.getCamPosX()
	%Pos.find_child("Y").find_child("Input").value = GDInterface.getCamPosY()
	%Pos.find_child("Z").find_child("Input").value = GDInterface.getCamPosZ()
	
	%Target.find_child("X").find_child("Input").value = GDInterface.getCamTargetX()
	%Target.find_child("Y").find_child("Input").value = GDInterface.getCamTargetY()
	%Target.find_child("Z").find_child("Input").value = GDInterface.getCamTargetZ()
	
	applyPointChanges()


func addPoint():
	
	pointNum += 1
	
	var point := SMSCamPoint.new()
	pointArray.append(point)
	
	%CurPointField.max_value = pointNum
	%CurPointField.min_value = 1.0
	%CurPointField.editable = true


func duplicatePoint():
	
	addPoint()
	pointArray[-1] = pointArray[%CurPointField.value - 1]


func deletePoint():
	
	var curPointIdx: int = %CurPointField.value - 1
	
	if pointNum == 1:
		resetPoints()
		return
	
	pointArray.pop_at(curPointIdx)
	updatePointEdit(0)
	%CurPointField.value = 0
	%CurPointField.max_value = pointNum - 1
	pointNum -= 1


func save(path: String):
	
	var saveFile := SaveFile.new()
	
	for i in pointNum:
		saveFile.positions.append(pointArray[i].position)
		saveFile.targets.append(pointArray[i].target)
		saveFile.times.append(pointArray[i].transitionTime)
		saveFile.interps.append(pointArray[i].interpolation)
	
	saveFile.saveFile(path)


func open(path: String):
	
	var file: SaveFile = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	resetPoints()
	print("file size: ", file.positions.size())
	for i in file.positions.size():
		if i != 0:	# b/c resetPoints() a couple of lines above auto-appends a single point
			pointArray.append(SMSCamPoint.new())
			pointNum += 1
		pointArray[i].position = file.positions[i]
		pointArray[i].target = file.targets[i]
		pointArray[i].transitionTime = file.times[i]
		pointArray[i].interpolation = file.interps[i]
	
	%CurPointField.max_value = pointNum
	updatePointEdit(%CurPointField.value)


func copyFromTarget() -> void:
	for button: Button in get_tree().get_nodes_in_group("GrabFromMario"):
		if button.button_pressed:
			button.button_pressed = false
			var parent: HBoxContainer = button.get_parent()
			var input: SpinBox = parent.find_child("Input")
			var getCamTarget := Callable(GDInterface, "getCamTarget" + parent.name)
			input.value = getCamTarget.call()
			
	applyPointChanges()


func copyFromCamPos() -> void:
	for button: Button in get_tree().get_nodes_in_group("GrabFromCamera"):
		if button.button_pressed:
			button.button_pressed = false
			var parent: HBoxContainer = button.get_parent()
			var input: SpinBox = parent.find_child("Input")
			var getCamPos := Callable(GDInterface, "getCamPos" + parent.name)
			input.value = getCamPos.call()
	
	applyPointChanges()


### SIGNALS ###

func _on_replay_points_pressed() -> void:
	replayPoints()


func _on_cur_point_field_value_changed(value: float) -> void:
	updatePointEdit(value)


func _on_grab_from_cam_pressed() -> void:
	grabFromCam()


func _on_add_point_pressed() -> void:
	addPoint()


func _on_any_point_field_changed(_value: float) -> void:
	applyPointChanges()


func _on_restore_camera_pressed() -> void:
	GDInterface.restoreCameraCode()


enum FileOptions {NEW, OPEN, SAVE, QUIT}
func _on_file_menu(id: int) -> void:
	
	match id:
		FileOptions.NEW:
			resetPoints()
		FileOptions.OPEN:
			%OpenFile.visible = true
		FileOptions.SAVE:
			%SaveAsFile.visible = true
		FileOptions.QUIT:
			get_tree().quit()
		_:
			push_error("Invalid file menu id!")


enum HelpOptions {BUG, GUIDE, LICENSE, ABOUT}
func _on_help_menu(id: int) -> void:
	
	match id:
		HelpOptions.BUG:
			OS.shell_open("https://github.com/AngryMax/sms-camera-tool/issues")
		HelpOptions.GUIDE:
			OS.shell_open("https://github.com/AngryMax/sms-camera-tool")	# TODO: make this link directly to the readme
		HelpOptions.LICENSE:
			OS.shell_open("https://github.com/AngryMax/sms-camera-tool/blob/main/LICENSE")
		HelpOptions.ABOUT:
			%About.visible = true
		_:
			push_error("Invalid help menu id!")

enum ViewOptions {VIEW_3D}
func _on_view_menu(id: int) -> void:
	
	match id:
		ViewOptions.VIEW_3D:
			%"3DViewPopup".visible = true
			%"3DViewPopup".process_mode = Node.PROCESS_MODE_ALWAYS	# TODO: perhaps do visiblity change and process_mode change through a variable set?
		_:
			push_error("Invalid view menu id!")


func _on_preview_point_pressed() -> void:
	previewMode = %PreviewPoint.button_pressed


func _on_interpolation_option_item_selected(index: int) -> void:
	pointArray[%CurPointField.value - 1].interpolation = index


signal new_points
func _on_open_file_file_selected(path: String) -> void:
	open(path)
	new_points.emit()


func _on_save_file_file_selected(path: String) -> void:
	save(path)


func _on_duplicate_point_pressed() -> void:
	duplicatePoint()


func _on_grab_from_target_toggled(toggled_on: bool) -> void:
	copyFromTarget()


func _on_grab_from_camera_toggled(toggled_on: bool) -> void:
	copyFromCamPos()


func _on_delete_button_pressed() -> void:
	deletePoint()

# TODO: perhaps make the below button it's own object? As in a button with auto-icon toggling?
var linkIcon: Texture2D = load("res://Resources/Images/link_icon.png")
var unlinkIcon: Texture2D = load("res://Resources/Images/unlink_icon.png")
func _on_link_transforms_button_toggled(toggled_on: bool) -> void:
	
	if toggled_on:
		%LinkTransformsButton.icon = linkIcon
	else:
		%LinkTransformsButton.icon = unlinkIcon
	
	linkTransforms = toggled_on
