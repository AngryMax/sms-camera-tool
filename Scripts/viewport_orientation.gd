extends Node3D

signal request_rotate_camera

func _ready() -> void:
	
	for child in get_children():
		if child is not Area3D:
			continue
		child.connect("input_event", _on_input_event)


enum Axis {X, Y, Z}
func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	
	if event is not InputEventMouseButton:
		return
	
	var mouse_click: InputEventMouseButton = event
	
	if not mouse_click.pressed:
		return
	
	print(event_position)
	
	var axisSign := "+"
	var posToArray := [event_position.x, event_position.y, event_position.z]
	
	var clickedAxisVal: float = posToArray.max()
	
	if abs(posToArray.min()) > clickedAxisVal:
		clickedAxisVal = posToArray.min()
	
	if clickedAxisVal < 0:
		axisSign = "-"
	
	var clickedAxis = posToArray.find(clickedAxisVal)
	
	var direction: String = Axis.keys()[clickedAxis] + axisSign
	
	request_rotate_camera.emit(direction)
