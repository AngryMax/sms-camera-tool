extends Node3D
class_name CamKeyframe

### NOTE: position and _targetPos should never be edited directly! Instead, smsPosition and smsTarget
### should be used in their stead!

### Public Vars ###
const UNIT_DIVIDE_RATIO := 1000	## How much we should divide SMS Units by when displaying here in Godot (since SMS's scale is much bigger)

var smsPosition: Vector3:	## Camera Position coordinates directly ripped from SMS
	set(value):
		smsPosition = value
		position = value / UNIT_DIVIDE_RATIO
var smsTarget: Vector3:	## Camera Target Position coordinates directly ripped from SMS
	set(value):
		smsTarget = value
		_targetPos = value / UNIT_DIVIDE_RATIO
var isSelected: bool:
	set(value):
		_targetSprite.visible = false
		_targetSprite.visible = value
		if value == true:
			_deactivateOtherKeyframes()
		isSelected = value
		keyframeChanged.emit(self)
var transitionTime: float
var interpolation: InterpolationTypes
enum InterpolationTypes {Linear, Cubic}	## Linear = 0, Cubic = 1
signal keyframeChanged(keyframe: CamKeyframe)	## Emitted to let the GUI know it needs to update

### Private Vars ###
var _targetSprite: Sprite3D
var _isMouseHovered := false		## If the mouse is currently hovering this ClickPoint
var _clickedOnPoint := false		## If there's currently a mouse click, tracks if that specific mouse click was on this ClickPoint
var _isBeingDragged := false		## If this ClickPoint is currently being dragged
var _SMSInterface: Node
var _targetPos: Vector3
const _pointTex := preload("res://Resources/Images/3d view sprites/point3.png")
const _mainScene := preload("res://Scenes/smsct.tscn")


### Override Funcs ###

func _init() -> void:
	print("init")
	position = Vector3.ZERO
	_targetPos = Vector3.ZERO
	transitionTime = 1.0
	interpolation = InterpolationTypes.Linear


func _ready() -> void:
	
	print("ready")
	
	_SMSInterface = get_tree().get_first_node_in_group("SMSCameraInterface")
	
	var colShape := CollisionShape3D.new()
	colShape.shape = SphereShape3D.new()
	colShape.debug_fill = true
	colShape.debug_color = Color(0.62, 0.0, 0.035, 1.0)
	colShape.shape.radius = 0.25
	
	var body := StaticBody3D.new()
	body.add_child(colShape)
	add_child(body)
	
	var posSprite := Sprite3D.new()
	posSprite.texture = _pointTex
	posSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	posSprite.scale = Vector3(2, 2, 2)
	posSprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
	body.add_child(posSprite)
	
	_targetSprite = Sprite3D.new()
	_targetSprite.texture = _pointTex
	_targetSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_targetSprite.scale = Vector3(2, 2, 2)
	_targetSprite.modulate = Color(0.076, 0.441, 0.0, 1.0)
	_targetSprite.position = to_local(_targetPos)
	#_targetSprite.visible = false
	body.add_child(_targetSprite)
	
	body.connect("input_event", _signalPassthrough)
	body.connect("mouse_entered", _on_mouse_entered)
	body.connect("mouse_exited", _on_mouse_exited)


func _process(_delta: float) -> void:
	_movePointByMouse()
	
	#if isSelected:
		#_targetSprite.visible = true


### Private Funcs ###

func _movePointByMouse() -> void:
	
	if not _isBeingDragged:
	
		if not _isMouseHovered:
			return

		if Input.is_action_just_pressed("mouse_click_left"):
			_isBeingDragged = true
			_clickedOnPoint = true

		if not _clickedOnPoint:
			return

	if not Input.is_action_pressed("mouse_click_left"):
		_isBeingDragged = false
		return
	
	var camera := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mousePos)
	var magnitude = from.distance_to(position)
	var to = from + camera.project_ray_normal(mousePos) * magnitude
	smsPosition.x = to.x * UNIT_DIVIDE_RATIO
	smsPosition.z = to.z * UNIT_DIVIDE_RATIO
	keyframeChanged.emit(self)

	# TODO: Add translate arrows instead of dragging the point around for the eventual move to true 3D


## DO NOT CALL THIS FUNC!! IT'S CALLED IN isSelected's SET!
func _deactivateOtherKeyframes() -> void:
	var _camKeyframes: Node3D = get_parent()
	for keyframe: CamKeyframe in _camKeyframes.get_children():
		if keyframe.isSelected == true and keyframe != self:
			keyframe.isSelected = false

### Public Funcs ###
	

func delete() -> void:
	queue_free()


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


func _on_mouse_entered() -> void:
	_isMouseHovered = true


func _on_mouse_exited() -> void:
	_isMouseHovered = false
	_clickedOnPoint = false
