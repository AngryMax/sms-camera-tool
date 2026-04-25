extends Node3D
class_name CamKeyframe

### Public Vars ###

var isSelected: bool:
	set(value):
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
var transitionTime: float
var interpolation: InterpolationTypes
var cameraPoint: Point
var targetPoint: Point
enum InterpolationTypes {Linear, Cubic}	## Linear = 0, Cubic = 1
signal keyframeChanged(keyframe: CamKeyframe)	## Emitted to let the GUI know it needs to update

### Private Vars ###
var _SMSInterface: Node
var _pointLink: PointLink
var _lastShowTargets: bool
const _mainScene := preload("res://Scenes/smsct.tscn")


### Override Funcs ###

func _init() -> void:
	transitionTime = 1.0
	interpolation = InterpolationTypes.Linear


func _ready() -> void:
	
	_SMSInterface = get_tree().get_first_node_in_group("SMSCameraInterface")
	
	cameraPoint = Point.new()
	targetPoint = Point.new()
	
	cameraPoint.color = Color(1.0, 0.635, 0.579, 1.0)
	cameraPoint.pointTex = preload("res://Resources/Images/3d view sprites/campoint.png")
	cameraPoint.position = Vector3(3, 4, 5)
	targetPoint.pointTex = preload("res://Resources/Images/target_icon.png")
	
	_pointLink = PointLink.new()
	
	add_child(_pointLink)
	add_child(cameraPoint)
	add_child(targetPoint)
	
	cameraPoint.body.connect("input_event", _signalPassthrough)
	cameraPoint.connect("pointUpdated", _on_point_updated)
	targetPoint.connect("pointUpdated", _on_point_updated)
	cameraPoint.connect("pointSelected", _on_point_selected)
	targetPoint.connect("pointSelected", _on_point_selected)


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


func _toggleArrowVisibility(toggle: bool) -> void:
	cameraPoint.dragArrowX.visible = toggle
	cameraPoint.dragArrowY.visible = toggle
	cameraPoint.dragArrowZ.visible = toggle
	targetPoint.dragArrowX.visible = toggle
	targetPoint.dragArrowY.visible = toggle
	targetPoint.dragArrowZ.visible = toggle


### Private Funcs ###



## DO NOT CALL THIS FUNC!! IT'S CALLED IN isSelected's SET!
func _deactivateOtherKeyframes() -> void:
	var _camKeyframes: Node3D = get_parent()
	for keyframe: CamKeyframe in _camKeyframes.get_children():
		if keyframe.isSelected == true and keyframe != self:
			keyframe.isSelected = false

### Public Funcs ###


### Signal Receiver Funcs ###

## Since the "input_event" signal that belongs to StaticBody3D doesn't seem to pass the object that's being
## clicked as a parameter, we go through the whole process of making this ClickObj and passing a processed
## version of the signal through here
func _signalPassthrough(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		
	var mouseButtonEvent: InputEventMouseButton
	
	if event is not InputEventMouseButton:
		return
	
	# Not *needed,* but I'd like to have this explicitly be InputEventMouseButton rather than just InputEvent
	mouseButtonEvent = event
	
	if mouseButtonEvent.pressed and mouseButtonEvent.button_mask == 1:
		isSelected = true

func _on_point_updated() -> void:
	keyframeChanged.emit(self)


func _on_point_selected(point: Point) -> void:
	if point == cameraPoint:
		cameraPoint.isSelected = true
		targetPoint.isSelected = false
	else:
		cameraPoint.isSelected = false
		targetPoint.isSelected = true
