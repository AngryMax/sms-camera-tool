extends Node3D
class_name Point

var _isMouseHovered := false		## If the mouse is currently hovering this ClickPoint
var _clickedOnPoint := false		## If there's currently a mouse click, tracks if that specific mouse click was on this ClickPoint
var _isBeingDragged := false		## If this ClickPoint is currently being dragged
var _sprite := Sprite3D.new()
var _hoveredDragArrow := HoveredDragArrow.NONE
var _snapDetect: ShapeCast3D
var _mouseLastPos := 0.0
var _isArrowBeingDragged := false
var _clickedOnArrow := false
var _lastHoveredArrow := HoveredDragArrow.NONE

enum HoveredDragArrow {NONE, X, Y, Z}

var smsPosition: Vector3:
	get:
		return position * Globals.UNIT_DIVIDE_RATIO
	set(value):
		position = value / Globals.UNIT_DIVIDE_RATIO
		smsPosition = value

var body: StaticBody3D
signal pointUpdated()	## Emitted to let the GUI know it needs to update
signal pointSetUndoRedo()	## Emitted to let the GUI know it needs to update, and when it shouldn't track the change for the Undo history
signal pointSelected(point: Point)	## Emitted to let the GUI know it needs to update
signal selectParentKeyframe()		## Emitted to the parent keyframe to flip _isSelected true
var pointTex: CompressedTexture2D
var color := Color(1.0, 1.0, 1.0, 1.0)
var dragArrowX: DragArrow
var dragArrowY: DragArrow
var dragArrowZ: DragArrow
var isSelected := false
var undoPos: Vector3
var holdTime := 0.0		## The time this Point is held on in seconds. <= 0 means do not hold.


func _ready() -> void:
	
	var colShape := CollisionShape3D.new()
	colShape.shape = SphereShape3D.new()
	colShape.debug_fill = true
	colShape.debug_color = Color(0.62, 0.0, 0.035, 1.0)
	colShape.shape.radius = 0.25
	
	body = StaticBody3D.new()
	#body.set_collision_mask_value(3, true)
	body.set_collision_layer_value(3, true)	# Used for the raycast during playback
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
	
	var snapRadius := SphereShape3D.new()
	
	_snapDetect = ShapeCast3D.new()
	_snapDetect.visible = true
	_snapDetect.shape = snapRadius
	_snapDetect.position += Vector3(0, 0.5 , 0)
	_snapDetect.enabled = false
	add_child(_snapDetect)
	
	dragArrowX.connect("mouse_entered", _on_mouse_entered_x)
	dragArrowX.connect("mouse_exited", _on_mouse_exited_x)
	dragArrowY.connect("mouse_entered", _on_mouse_entered_y)
	dragArrowY.connect("mouse_exited", _on_mouse_exited_y)
	dragArrowZ.connect("mouse_entered", _on_mouse_entered_z)
	dragArrowZ.connect("mouse_exited", _on_mouse_exited_z)
	body.connect("mouse_entered", _on_mouse_entered)
	body.connect("mouse_exited", _on_mouse_exited)
	
	Globals.undoRedo.connect("version_changed", _on_undo_redo)
	
	undoPos = position


func _process(_delta: float) -> void:
	_movePointByMouse()
	_movePointByDragArrows()
	
	if isSelected:
		_sprite.modulate = Color(0.0, 0.5, 0.0, 1.0)
	
	if (_isBeingDragged or _isArrowBeingDragged) and Globals.snapMode == Globals.SnapMode.POINT:
		var snapPoint: Point = _getSnapPoints()
		
		if snapPoint == null:
			return
		
		position = snapPoint.position


func updateLabel() -> void:
	for child in get_children():
		if child is Label3D:
			child.text = str(get_parent().get_index() + 1)


func setPosition(pos: Vector3, isSMSPos := true) -> void:
	
	if isSMSPos:
		pos /= Globals.UNIT_DIVIDE_RATIO
	
	position = pos
	_setUndoRedo()


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
		
		return

	if not Input.is_action_pressed("mouse_click_left"):
		_setUndoRedo()
		_isBeingDragged = false
		return
	
	
	# 1st click to select, second click to drag around. This prevents moving the Point as soon as it's selected
	if not isSelected:
		_isBeingDragged = false
		_clickedOnPoint = false
		pointSelected.emit(self)
		return
	
	var camera := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mousePos)
	var magnitude = from.distance_to(position)
	var to = from + camera.project_ray_normal(mousePos) * magnitude
	
	position = Vector3(to.x, position.y, to.z)
	
	pointUpdated.emit()


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
		_clickedOnArrow = false
		_setUndoRedo()
		return
	
	var camera := get_viewport().get_camera_3d()
	var mousePos := get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mousePos)
	var magnitude = from.distance_to(position)
	var to = from + camera.project_ray_normal(mousePos) * magnitude
	
	if not _isArrowBeingDragged:	# Have to do this after the mouse to position calcs
		return
	
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
	
	pointUpdated.emit()


## If another Point is nearby this Point, return a reference to the nearby Point. Otherwise, return null.
func _getSnapPoints() -> Point:
	
	_snapDetect.force_shapecast_update()
	
	if not _snapDetect.collide_with_bodies:	# I don't think this ever gets hit since _snapDetect will collide with colShape, but posterity sake
		return null
	
	var collisions: Array = _snapDetect.collision_result
	
	for colInfo: Dictionary in collisions:
		var colBody: StaticBody3D = colInfo.collider
		var parent = colBody.get_parent()
		if parent is Point and parent != self:
			return parent
		else:
			continue
	
	return null


## Call this to basically append the current position into the undo history
func _setUndoRedo() -> void:
	pointSetUndoRedo.emit(self)
	undoPos = position


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


func _on_undo_redo() -> void:	## Called *ANY* TIME the Undo or Redo action is used
	
	# This is a really sloppy bug fix. Since this function is connected to
	# Globals.undoRedo.version_changed, that means that any time undoRedo does
	# basically anything, regardless of its relation to this Point, that this
	# function gets called-- which in practice meant that the highest indexed
	# CamKeyframe would always become selected whenever any other CamKeyframe
	# was changed. I only really want this function to be called when
	# Globals.undoRedo is acting on THIS Point, which is what the if statement
	# below is filtering for. This is what it's specifically doing:
	# If the parent CamKeyframe is not selected, we then check to see if any
	# of the other CamKeyframes are selected. If true, then we return.
	# If there is no other selected CamKeyframe, then we know that the current
	# undoRedo action is focus on this Point, so we continue to the rest of this func.
	if get_parent().isSelected == false:
		var isAnyOtherKeyframeSelected := false
		for keyframe in get_parent().get_parent().get_children():	# for CamKeyframe in self -> CamKeyframe -> CamKeyframes
			if keyframe.isSelected:
				isAnyOtherKeyframeSelected = true
		
		if isAnyOtherKeyframeSelected:
			return
		
	
	pointUpdated.emit()
	selectParentKeyframe.emit()
	undoPos = position
