extends Node

### Global Vars

const UNIT_DIVIDE_RATIO = 100 ## How much we should divide SMS Units by when displaying here in Godot (since SMS's scale is much bigger)

var currentKeyframe: CamKeyframe	## The keyframe that's selected in the GUI

var undoRedo := UndoRedo.new()


### Settings

var showTargets: bool = false		## If ALL targetPoints should be visible always

enum SnapMode {NONE, POINT, GRID}
var snapMode := SnapMode.NONE

var camPointFollowViewport := false		## currentKeyframe's camPoint will update it's position to the viewport camera's
var targetPointFollowViewport := false	## currentKeyframe's targetPoint will update it's position to the viewport camera's


### Settings Parameters

var viewportCameraStartPos: Vector3	## The spawn coords of the viewport camera. Set in the Camera3D's _ready()
var viewportCameraStartRot: Vector3	## The spawn rot of the viewport camera. Set in the Camera3D's _ready()

var enableShaders := false
