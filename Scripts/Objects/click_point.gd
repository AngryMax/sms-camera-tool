extends Node3D
class_name ClickPoint

signal clicked(clickObj: ClickPoint)
const pointTex := preload("res://Resources/Images/3d view sprites/point3.png")

var targetPos: Vector3
var targetSprite: Sprite3D
var isActive: bool:
	set(value):
		isActive = value
		targetSprite.visible = value
		print(value)

var _isMouseHovered := false		## If the mouse is currently hovering this ClickPoint
var _clickedOnPoint := false		## If there's currently a mouse click, tracks if that specific mouse click was on this ClickPoint
var _isBeingDragged := false		## If this ClickPoint is currently being dragged


func _ready() -> void:
	
	var colShape := CollisionShape3D.new()
	colShape.shape = SphereShape3D.new()
	colShape.debug_fill = true
	colShape.debug_color = Color(0.62, 0.0, 0.035, 1.0)
	colShape.shape.radius = 0.25
	
	var body := StaticBody3D.new()
	body.add_child(colShape)
	add_child(body)
	
	var posSprite := Sprite3D.new()
	posSprite.texture = pointTex
	posSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	posSprite.scale = Vector3(2, 2, 2)
	posSprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
	body.add_child(posSprite)
	
	targetSprite = Sprite3D.new()
	targetSprite.texture = pointTex
	targetSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	targetSprite.scale = Vector3(2, 2, 2)
	targetSprite.modulate = Color(0.076, 0.441, 0.0, 1.0)
	targetSprite.position = to_local(targetPos)
	targetSprite.visible = false
	body.add_child(targetSprite)
	
	body.connect("input_event", signalPassthrough)
	body.connect("mouse_entered", _on_mouse_entered)
	body.connect("mouse_exited", _on_mouse_exited)


func _process(_delta: float) -> void:
	_movePointByMouse()


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
	position.x = to.x
	position.z = to.z
	
	# TODO: Add translate arrows instead of dragging the point around for the eventual move to true 3D
	


### Signals ###

## Since the "input_event" signal that belongs to StaticBody3D doesn't seem to pass the object that's being
## clicked as a parameter, we go through the whole process of making this ClickObj and passing a processed
## version of the signal through here
func signalPassthrough(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
		
	var mouseButtonEvent: InputEventMouseButton
	
	if event is not InputEventMouseButton:
		return
	
	# Not *needed,* but I'd like to have this explicitly be InputEventMouseButton rather than just InputEvent
	mouseButtonEvent = event
	
	if mouseButtonEvent.pressed and mouseButtonEvent.button_mask == 1:
		clicked.emit(self)
		isActive = not isActive


func _on_mouse_entered() -> void:
	print("mouse entered! :D")
	_isMouseHovered = true


func _on_mouse_exited() -> void:
	_isMouseHovered = false
	_clickedOnPoint = false
