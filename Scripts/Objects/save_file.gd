class_name SaveFile
extends Resource

# IMPORTANT NOTE!! If this file is ever renamed or moved, that will make all previous save files
# incompatible unless manually edited!

@export var positions: Array[Vector3]
@export var targets: Array[Vector3]
@export var ease: Array[Globals.EaseDirection]
@export var camHold: Array[float]
@export var targetHold: Array[float]
@export var playbackTime: float


func _init() -> void:
	_reset()


func _reset() -> void:
	positions.clear()
	targets.clear()
	ease.clear()
	playbackTime = 1.0
	camHold.clear()
	targetHold.clear()


func saveFile(path: String) -> void:
	ResourceSaver.save(self, path)
	_reset()
	
