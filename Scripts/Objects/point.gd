extends Node3D
class_name Point

var _isMouseHovered := false		## If the mouse is currently hovering this ClickPoint
var _clickedOnPoint := false		## If there's currently a mouse click, tracks if that specific mouse click was on this ClickPoint
var _isBeingDragged := false		## If this ClickPoint is currently being dragged
var _sprite := Sprite3D.new()

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

	body.connect("mouse_entered", _on_mouse_entered)
	body.connect("mouse_exited", _on_mouse_exited)


func _process(_delta: float) -> void:
	_movePointByMouse()


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


### Signal Receiver Funcs ###

func _on_mouse_entered() -> void:
	_isMouseHovered = true


func _on_mouse_exited() -> void:
	_isMouseHovered = false
	_clickedOnPoint = false
