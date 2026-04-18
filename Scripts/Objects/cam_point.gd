
class_name SMSCamPoint

enum InterpolationTypes {Linear, Spheric}	## Linear = 0, Spheric = 1

var position: Vector3
var target: Vector3
var transitionTime: float
var interpolation: InterpolationTypes

func _init() -> void:
	position = Vector3.ZERO
	target = Vector3.ZERO
	transitionTime = 1.0
	interpolation = InterpolationTypes.Linear
