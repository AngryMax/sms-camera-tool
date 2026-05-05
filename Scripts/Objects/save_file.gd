class_name SaveFile
extends Resource

# IMPORTANT NOTE!! If this file is ever renamed or moved, that will make all previous save files
# incompatible unless manually edited!

@export var positions: Array[Vector3]
@export var targets: Array[Vector3]
@export var times: Array[float]
@export var ease: Array[Globals.EaseDirection]
@export var playbackTime: float

func _init() -> void:
	_reset()


func _reset() -> void:
	positions.clear()
	targets.clear()
	times.clear()
	ease.clear()
	playbackTime = 1.0


func saveFile(path: String) -> void:
	ResourceSaver.save(self, path)
	_reset()
	
