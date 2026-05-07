## This script is responsible for all interactions that involve both Sunshine and
## SMSCT. Basically, this is the connective tissue between the GDInterface and
## the keyframe editor. No other script or object should be calling GDInterface!

extends Node
class_name SMSCameraInterface

@export var GDInterface: Node
@export var camKeyframesNode: Node3D


var previewMode := false		# TODO: make previewMode and playbackMode into a state machine
var playbackTime := 1.0
var playbackMode := false:
	set(value):
		playbackMode = value
		if value == true:
			_preparingPlayback = true

var position: Vector3:
	get:
		return _getCameraPosition()
var target: Vector3:
	get:
		return _getCameraTargetPosition()

var _keyframes: Array[CamKeyframe]
var _preparingPlayback := true	## Used in _replayKeyframes to track state. This will get refactored as an Enter() func in the state machine update
var _lerpPow := 0.0:				## lerpPow is my personal convention for what to call t in the lerp() equation.
	set(value):
		_lerpPow = clampf(value, 0.0, 1.0)	# Perhaps unnecessary, since the way I'm coding this it should basically be auto-clamped

var _playbackStartTimer := 0.0

### Override Funcs ##

func _ready() -> void:
	GDInterface = %GDInterface
	GDInterface.Hook()


func _process(delta: float) -> void:
	_previewKeyframe(Globals.currentKeyframe)
	_replayKeyframes(delta)


### Public Funcs ###

func getCoord(lambda: String) -> float:
	var callFunc := Callable(GDInterface, lambda)
	return callFunc.call()


### Private Funcs ###

func _replayKeyframes(delta: float):
	
	if not playbackMode:
		return
	
	if _preparingPlayback:
		_preparePlayback()
		return
	
	var curPos: Vector3
	var curTarget: Vector3
	
	
	var camCurve: Curve3D = %CameraRail.curve
	var targetCurve: Curve3D = %TargetRail.curve
	
	if camCurve.point_count <= 1:
		curPos = _keyframes.front().cameraPoint.smsPosition
	else:
		%CamRailFollow.progress_ratio = _lerpPow
		curPos = %CamRailFollow.position * Globals.UNIT_DIVIDE_RATIO
	
	if targetCurve.point_count <= 1:
		curTarget = _keyframes.front().targetPoint.smsPosition
	else:
		%TargetRailFollow.progress_ratio = _lerpPow
		curTarget = %TargetRailFollow.position * Globals.UNIT_DIVIDE_RATIO
	
	GDInterface.writeCamData(curPos, curTarget)
	setSMSCamRepTransform(curPos / Globals.UNIT_DIVIDE_RATIO, curTarget / Globals.UNIT_DIVIDE_RATIO)
	
	const WAIT_AT_START_TIMER = 0.5
	if _playbackStartTimer > WAIT_AT_START_TIMER:	# Hold 0.5 seconds on the first keyframe before moving
		_lerpPow += delta / playbackTime	# It's kinda weird but we want to add on delta AFTER doing our lerping
	
	_playbackStartTimer += delta
	
	if _lerpPow >= 1.0:
		_lerpPow = 0.0
		GDInterface.restoreCameraCode()
		playbackMode = false
		return


func setSMSCamRepTransform(setPos: Vector3, setTarget: Vector3) -> void:
	%Timer.start()
	if not %SMSCameraRepresantation.visible:
		%SMSCameraRepresantation.visible = true
	%CamModel.position = setPos
	%CamModel.look_at(setTarget)
	%TargetModel.position = setTarget
	


## Sets the _keyframes array + other playback prep work.
func _preparePlayback() -> void:
	
	_keyframes.clear()
	
	# Set our keyframe array
	for i in camKeyframesNode.get_child_count():
		_keyframes.append(camKeyframesNode.get_child(i))
	
	# Misc prep work
	GDInterface.nopOutCameraCode()
	_preparingPlayback = false
	_lerpPow = 0
	previewMode = false
	_playbackStartTimer = 0.0
	
	var camCurve: Curve3D = %CameraRail.curve
	var targetCurve: Curve3D = %TargetRail.curve
	var lastCamPos: Vector3
	var lastTargetPos: Vector3
	var firstLoop := true
	camCurve.clear_points()
	targetCurve.clear_points()
	
	for keyframe: CamKeyframe in _keyframes:
		
		if firstLoop:
			camCurve.add_point(keyframe.cameraPoint.position)
			targetCurve.add_point(keyframe.targetPoint.position)
			lastCamPos = keyframe.cameraPoint.position
			lastTargetPos = keyframe.targetPoint.position
			firstLoop = false
			continue
		
		# NOTE: Since the Playback time system has replaced the Transition time system, this means
		# that we're allowed to (actually, have to) SKIP adding points to our Curve3Ds that are
		# identical to the last point! So with this implementation, our Curves can have LESS points
		# than Keyframes! This also means that holding on points before moving to other points is
		# currently impossible, which will have to be changed! (TODO)
		if keyframe.cameraPoint.position != lastCamPos:
			camCurve.add_point(keyframe.cameraPoint.position)
			lastCamPos = keyframe.cameraPoint.position
		if keyframe.targetPoint.position != lastTargetPos:
			targetCurve.add_point(keyframe.targetPoint.position)
			lastTargetPos = keyframe.targetPoint.position


var _lastState := false
func _previewKeyframe(keyframe: CamKeyframe):
	
	if _lastState == true and previewMode == false:
		GDInterface.restoreCameraCode()
		_lastState = false
	
	if not previewMode:
		return
	
	_lastState = true
	
	GDInterface.nopOutCameraCode()
	GDInterface.writeCamData(keyframe.cameraPoint.smsPosition, keyframe.targetPoint.smsPosition)


## Get's Sunshine's camera position
func _getCameraPosition() -> Vector3:
	return Vector3(GDInterface.getCamPosX(), GDInterface.getCamPosY(), GDInterface.getCamPosZ())


## Get's Sunshine's camera target position
func _getCameraTargetPosition() -> Vector3:
	return Vector3(GDInterface.getCamTargetX(), GDInterface.getCamTargetY(), GDInterface.getCamTargetZ())


## direction should either be Vector3.UP or Vector3.DOWN
func _getEasingHandle(from: Vector3, to: Vector3, direction: Vector3) -> Vector3:
	
	var mid := (from + to) / 2.0
	var ab := to - from
	var perp := ab.cross(Vector3.DOWN).normalized()
	var offset := perp * ab.length() / 2.0
	var handle := mid + offset
	
	return handle

## Linear camera interpolation | Only to be called by replayPoints()
func _interpolateLinear(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	return from.lerp(to, lerpPow)


## Cubic camera interpolation | Only to be called by replayPoints()
func _interpolateCubic(from: Vector3, to: Vector3, pre_from: Vector3, pre_to: Vector3, lerpPow: float) -> Vector3:	# TODO: actually figure this out lol
	return from.cubic_interpolate(to, pre_from, pre_to, lerpPow)


## Smooth camera interpolation (also cubic) | Only to be called by replayPoints()
func _interpolateSmooth(from: Vector3, to: Vector3, lerpPow: float) -> Vector3:
	lerpPow = smoothstep(0, 1, lerpPow)
	return from.lerp(to, lerpPow)


func _on_timer_timeout() -> void:
	%SMSCameraRepresantation.visible = false
	%Timer.stop()
