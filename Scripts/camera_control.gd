# Thanks to https://www.youtube.com/watch?v=ZCb12AHKMfE
# This script is responsible for camera rotation via the mouse

extends Camera3D

@export var MOUSE_SENS: float = 0.005
@export_range(-180, 0.0, 0.1, "radians_as_degrees") var MIN_VERT_ANGLE = -PI/2
@export_range(0.0, -180.0, 0.1, "radians_as_degrees") var MAX_VERT_ANGLE = PI/4


func _ready() -> void:
	Globals.viewportCameraStartPos = position
	Globals.viewportCameraStartRot = rotation


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_pressed("mouse_click_right"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
		
	if not Input.is_action_pressed("mouse_click_right"):
		return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y -= event.relative.x * MOUSE_SENS
		rotation.y = wrap(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * MOUSE_SENS
		rotation.x = clamp(rotation.x, MIN_VERT_ANGLE, MAX_VERT_ANGLE)
