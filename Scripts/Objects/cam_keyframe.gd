extends Node3D
class_name CamKeyframe

### NOTE: position and _targetPos should (almost) never be edited directly!
### Instead, smsPosition and smsTarget should be used in their stead!

### Public Vars ###

var isSelected: bool:
	set(value):
		targetPoint.visible = value
		_toggleArrowVisibility(value)
		if value == true:
			_deactivateOtherKeyframes()
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
	targetPoint.pointTex = preload("res://Resources/Images/target_icon.png")
	
	add_child(cameraPoint)
	add_child(targetPoint)
	
	cameraPoint.body.connect("input_event", _signalPassthrough)
	cameraPoint.connect("pointChanged", _pointChanged)
	targetPoint.connect("pointChanged", _pointChanged)


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

func _pointChanged(_point: Point) -> void:
	keyframeChanged.emit(self)
