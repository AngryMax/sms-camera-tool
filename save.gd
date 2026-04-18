class_name SaveFile
extends Resource

@export var positions: Array[Vector3]
@export var targets: Array[Vector3]
@export var times: Array[float]
@export var interps: Array[SMSCamPoint.InterpolationTypes]

func saveFile() -> void:
	ResourceSaver.save(self, "user://save.tres")
	_reset()
	

func _reset() -> void:
	positions.clear()
	targets.clear()
	times.clear()
	interps.clear
