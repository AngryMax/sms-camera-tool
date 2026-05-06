extends Node3D
class_name CamKeyframe

### Public Vars ###

var isSelected: bool:
	set(value):
		if get_parent().name != "CamKeyframes":
			value = false
		targetPoint.visible = value or Globals.showTargets
		_pointLink.visible = value
		_toggleArrowVisibility(value)
		if value == true:
			_deactivateOtherKeyframes()
		if value == false:
			cameraPoint.isSelected = false
			targetPoint.isSelected = false
		isSelected = value
		keyframeChanged.emit(self)
var transitionTime: float:	## NOTE: CURRENTLY UNUSED!!
		set(value):
			_markUnsaved()
			transitionTime = value
var easeDirection: Globals.EaseDirection:
		set(value):
			_markUnsaved()
			easeDirection = value
var cameraPoint: Point
var targetPoint: Point
var index: int	## Used for undo/redoing. Not always an accurate potrayal of this Keyframe's index!
signal keyframeChanged(keyframe: CamKeyframe)	## Emitted to let the GUI know it needs to update

### Private Vars ###
var _SMSInterface: Node
var _pointLink: PointLink
var _lastShowTargets: bool
const _mainScene := preload("res://Scenes/smsct.tscn")


### Override Funcs ###

func _init() -> void:
	transitionTime = 1.0
	easeDirection = Globals.EaseDirection.NONE


func _ready() -> void:
	
	_SMSInterface = get_tree().get_first_node_in_group("SMSCameraInterface")
	
	if cameraPoint == null:
		cameraPoint = Point.new()
		cameraPoint.color = Color(1.0, 0.635, 0.579, 1.0)
		cameraPoint.pointTex = preload("res://Resources/Images/3d view sprites/campoint.png")
		cameraPoint.position = Vector3(3, 4, 5)
		add_child(cameraPoint)
	
	
	if targetPoint == null:
		targetPoint = Point.new()
		targetPoint.pointTex = preload("res://Resources/Images/target_icon.png")
		add_child(targetPoint)
	
	_pointLink = PointLink.new()
	add_child(_pointLink)
	
	cameraPoint.body.connect("input_event", _on_body_mouse_input)
	cameraPoint.connect("pointUpdated", _on_point_updated)
	targetPoint.connect("pointUpdated", _on_point_updated)
	cameraPoint.connect("pointSetUndoRedo", _on_point_set_undo_redo)
	targetPoint.connect("pointSetUndoRedo", _on_point_set_undo_redo)
	cameraPoint.connect("pointSelected", _on_point_selected)
	targetPoint.connect("pointSelected", _on_point_selected)
	cameraPoint.connect("selectParentKeyframe", _on_request_selected)
	targetPoint.connect("selectParentKeyframe", _on_request_selected)
	self.connect("tree_exiting", _on_tree_exiting)
	
	index = get_index()


func _process(_delta: float) -> void:
	
	_pointLink.start  = cameraPoint.position
	_pointLink.end = targetPoint.position
	
	if Globals.showTargets:
		targetPoint.visible = true
		_pointLink.visible = true
		_lastShowTargets = Globals.showTargets
	
	if _lastShowTargets != Globals.showTargets and isSelected == false:
		targetPoint.visible = false
		_pointLink.visible = false
	
	if not isSelected:
		return
	
	if Globals.camPointFollowViewport:
		cameraPoint.position = get_viewport().get_camera_3d().position
		keyframeChanged.emit(self)
	
	if Globals.targetPointFollowViewport:
		targetPoint.position = get_viewport().get_camera_3d().position
		keyframeChanged.emit(self)


### Private Funcs ###


func _toggleArrowVisibility(toggle: bool) -> void:
	cameraPoint.dragArrowX.visible = toggle
	cameraPoint.dragArrowY.visible = toggle
	cameraPoint.dragArrowZ.visible = toggle
	targetPoint.dragArrowX.visible = toggle
	targetPoint.dragArrowY.visible = toggle
	targetPoint.dragArrowZ.visible = toggle


## Called in CamKeyframe's member's var setters. 
func _markUnsaved() -> void:
	
	if Globals.curFileName.ends_with("*"):
		return
	
	Globals.curFileName = Globals.curFileName + "*"


## NOTE: DO NOT CALL THIS FUNC!! IT'S CALLED IN isSelected's SET!
func _deactivateOtherKeyframes() -> void:
	var _camKeyframes: Node3D = get_parent()
	if _camKeyframes == null:	## Currently a safeguard, but could cause bugs if I don't keep in mind
		queue_free()
		return
	for keyframe: CamKeyframe in _camKeyframes.get_children():
		if keyframe.isSelected == true and keyframe != self:
			keyframe.isSelected = false

### Public Funcs ###


### Signal Receiver Funcs ###

## Since the "input_event" signal that belongs to StaticBody3D doesn't seem to pass the object that's being
## clicked as a parameter, we go through the whole process of making this ClickObj and passing a processed
## version of the signal through here
func _on_body_mouse_input(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		
	var mouseButtonEvent: InputEventMouseButton
	
	if event is not InputEventMouseButton:
		return
	
	# Not *needed,* but I'd like to have this explicitly be InputEventMouseButton rather than just InputEvent
	mouseButtonEvent = event
	
	if mouseButtonEvent.pressed and mouseButtonEvent.button_mask == 1:
		isSelected = true


func _on_point_updated() -> void:
	keyframeChanged.emit(self)
	_markUnsaved()


## For making this the selected keyframe from child nodes (IE: when a point gets ctrl + z'd)
func _on_request_selected() -> void:
	isSelected = true


func _on_point_set_undo_redo(point: Point) -> void:
	
	Globals.undoRedo.create_action("Point")
	Globals.undoRedo.add_undo_property(point, "position", point.undoPos)
	Globals.undoRedo.add_do_property(point, "position", point.position)
	Globals.undoRedo.commit_action()
	
	point.undoPos = point.position


func _on_point_selected(point: Point) -> void:
	if point == cameraPoint:
		cameraPoint.isSelected = true
		targetPoint.isSelected = false
	else:
		cameraPoint.isSelected = false
		targetPoint.isSelected = true


func _on_tree_exiting() -> void:
	print("here")
	cameraPoint.isSelected = false
	targetPoint.isSelected = false
	isSelected = false
