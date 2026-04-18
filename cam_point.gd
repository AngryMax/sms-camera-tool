
class_name SMSCamPoint

enum InterpolationTypes {Linear, Spheric}

var position: Vector3
var target: Vector3
var transitionTime: float
var interpolation: InterpolationTypes

func _init() -> void:
	position = Vector3.ZERO
	target = Vector3.ZERO
	transitionTime = 1.0
	interpolation = InterpolationTypes.Linear
