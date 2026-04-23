extends Node3D
class_name ClickPoint

signal clicked(clickObj: ClickPoint)
const pointTex := preload("res://Resources/Images/3d view sprites/point2.png")

func _ready() -> void:
	
	var colShape := CollisionShape3D.new()
	colShape.shape = SphereShape3D.new()
	#colShape.debug_fill = true
	#colShape.debug_color = Color(0.62, 0.0, 0.035, 1.0)
	colShape.shape.radius = 0.25
	
	var body := StaticBody3D.new()
	body.add_child(colShape)
	add_child(body)
	
	var pointSprite := Sprite3D.new()
	pointSprite.texture = pointTex
	pointSprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pointSprite.scale = Vector3(2, 2, 2)
	body.add_child(pointSprite)
	
	body.connect("input_event", signalPassthrough)


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
