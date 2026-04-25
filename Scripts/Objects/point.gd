extends Node3D
class_name Point

var _isMouseHovered := false		## If the mouse is currently hovering this ClickPoint
var _clickedOnPoint := false		## If there's currently a mouse click, tracks if that specific mouse click was on this ClickPoint
var _isBeingDragged := false		## If this ClickPoint is currently being dragged
var _sprite := Sprite3D.new()
var _hoveredDragArrow := HoveredDragArrow.NONE

enum HoveredDragArrow {NONE, X, Y, Z}

var smsPosition: Vector3:
	get:
		return position * Globals.UNIT_DIVIDE_RATIO
	set(value):
		position = value /  Globals.UNIT_DIVIDE_RATIO
		print("sms: ", value, " | godot: ", position)
		smsPosition = value
var body: StaticBody3D
signal pointChanged(point: Point)	## Emitted to let the GUI know it needs to update
var pointTex := preload("res://Resources/Images/3d view sprites/point3.png")
var color := Color(1.0, 1.0, 1.0, 1.0)
var dragArrowX: DragArrow
var dragArrowY: DragArrow
var dragArrowZ: DragArrow


func _ready() -> void:
	
	var colShape := CollisionShape3D.new()
	colShape.shape = SphereShape3D.new()
	colShape.debug_fill = true
	colShape.debug_color = Color(0.62, 0.0, 0.035, 1.0)
	colShape.shape.radius = 0.25
	
	body = StaticBody3D.new()
	body.add_child(colShape)
	add_child(body)
	
	_sprite.texture = pointTex
	_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_sprite.scale = Vector3(2, 2, 2)
	_sprite.modulate = color
	body.add_child(_sprite)
	
	dragArrowX = DragArrow.new()
	dragArrowX.axis = DragArrow.Axis.X
	add_child(dragArrowX)
	dragArrowY = DragArrow.new()
	dragArrowY.axis = DragArrow.Axis.Y
	add_child(dragArrowY)
	dragArrowZ = DragArrow.new()
	dragArrowZ.axis = DragArrow.Axis.Z
	add_child(dragArrowZ)
	
	var numLabel = Label3D.new()
	numLabel.text = str(get_parent().get_index() + 1)
	numLabel.font_size = 118
	numLabel.outline_size = 24
	numLabel.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	numLabel.position += Vector3(-0.5, 0.75, 0)
	add_child(numLabel)
	
	
	dragArrowX.connect("mouse_entered", _on_mouse_entered_x)
	dragArrowX.connect("mouse_exited", _on_mouse_exited_x)
	dragArrowY.connect("mouse_entered", _on_mouse_entered_y)
	dragArrowY.connect("mouse_exited", _on_mouse_exited_y)
	dragArrowZ.connect("mouse_entered", _on_mouse_entered_z)
	dragArrowZ.connect("mouse_exited", _on_mouse_exited_z)
	body.connect("mouse_entered", _on_mouse_entered)
	body.connect("mouse_exited", _on_mouse_exited)


func _process(_delta: float) -> void:
	_movePointByMouse()
	_movePointByDragArrows()


func updateLabel() -> void:
	print("updating label")
	for child in get_children():
		if child is Label3D:
			child.text = str(get_parent().get_index() + 1)


func _movePointByMouse() -> void:
	
	if not visible:
		return
	
	_sprite.modulate = color
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
	
	_sprite.modulate = Color(0.0, 0.5, 0.0, 1.0)
	var camera := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mousePos)
	var magnitude = from.distance_to(position)
	var to = from + camera.project_ray_normal(mousePos) * magnitude
	position.x = to.x
	position.z = to.z
	pointChanged.emit(self)


var _mouseLastPos := 0.0
var _isArrowBeingDragged := false
var _clickedOnArrow := false
var _lastHoveredArrow := HoveredDragArrow.NONE
func _movePointByDragArrows():
	
	if not visible:
		return
	
	if not _isArrowBeingDragged:
		
		if _hoveredDragArrow == HoveredDragArrow.NONE:
			return
			
		_lastHoveredArrow = _hoveredDragArrow
		
		if Input.is_action_just_pressed("mouse_click_left"):
			_isArrowBeingDragged = true
			_clickedOnArrow = true
		
		if not _clickedOnArrow:
			return
			
	if not Input.is_action_pressed("mouse_click_left"):
		_isArrowBeingDragged = false
		return
	
	_sprite.modulate = Color(0.0, 0.5, 0.0, 1.0)
	
	var camera := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mousePos)
	var magnitude = from.distance_to(position)
	var to = from + camera.project_ray_normal(mousePos) * magnitude
	
	match(_lastHoveredArrow):
		HoveredDragArrow.X:
			if to.x != _mouseLastPos and not Input.is_action_just_pressed("mouse_click_left"):
				position.x +=  to.x - _mouseLastPos
			_mouseLastPos = to.x
			
		HoveredDragArrow.Y:
			if to.y != _mouseLastPos and not Input.is_action_just_pressed("mouse_click_left"):
				position.y +=  to.y - _mouseLastPos
			_mouseLastPos = to.y
			
		HoveredDragArrow.Z:
			if to.z != _mouseLastPos and not Input.is_action_just_pressed("mouse_click_left"):
				position.z +=  to.z - _mouseLastPos
			_mouseLastPos = to.z
			
		_:
			push_error("...how did we even get here?")
			return
	
	pointChanged.emit(self)


### Signal Receiver Funcs ###

func _on_mouse_entered() -> void:
	_isMouseHovered = true


func _on_mouse_entered_x() -> void:
	_hoveredDragArrow = HoveredDragArrow.X

func _on_mouse_exited_x() -> void:
	if _hoveredDragArrow == HoveredDragArrow.X:
		_hoveredDragArrow = HoveredDragArrow.NONE
		_clickedOnArrow = false
	
func _on_mouse_entered_y() -> void:
	_hoveredDragArrow = HoveredDragArrow.Y

func _on_mouse_exited_y() -> void:
	if _hoveredDragArrow == HoveredDragArrow.Y:
		_hoveredDragArrow = HoveredDragArrow.NONE
		_clickedOnArrow = false
	
func _on_mouse_entered_z() -> void:
	_hoveredDragArrow = HoveredDragArrow.Z

func _on_mouse_exited_z() -> void:
	if _hoveredDragArrow == HoveredDragArrow.Z:
		_hoveredDragArrow = HoveredDragArrow.NONE
		_clickedOnArrow = false


func _on_mouse_exited() -> void:
	_isMouseHovered = false
	_clickedOnPoint = false
